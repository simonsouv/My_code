#!/usr/bin/env bash
#set -x
# shell script executing tcpdump to catch network traffic
# then produce statistics by endpoints (#of packets TX/TX; #bytes TX/RX)
# requirements:
#   Ability to execute tcpdump (pacroot account or sudo)
#

function erreur(){
  echo $1
  exit 1
}

# hard-coded value to be passed as args later
TCPDUMP_SAMPLING=3 #sampline in seconds
NUMBER_OF_SAMPLING=1 #number of runs to execute
IFACE=bond0 #interface to filter on
OUTPUT_DIR=/tmp/tcpdump_analysis
PYTHON_TCPDUMP_ANALYSIS=/tmp/tcpdump_analysis.py

[ -d $OUTPUT_DIR ] || mkdir $OUTPUT_DIR || erreur "Cannot create $OUTPUT_DIR"

rm $OUTPUT_DIR/tcpdump_*

unset PYTHONHOME
for i in $(seq 1 $NUMBER_OF_SAMPLING);do
  echo "tcpdump exec #$i for $TCPDUMP_SAMPLING seconds"
  TS=`date +%s` # get EPOCH current date
  timeout $TCPDUMP_SAMPLING tcpdump -i $IFACE -l -w $OUTPUT_DIR/tcpdump_${TS}.raw ip
  echo "read $OUTPUT_DIR/tcpdump_${TS}.raw into $OUTPUT_DIR/tcpdump_${TS}.out"
  tcpdump -N -v -r $OUTPUT_DIR/tcpdump_${TS}.raw > /$OUTPUT_DIR/tcpdump_${TS}.tmp
  awk '$0~/^[0-9]/{l=$0;getline}$0~/^ /{l=l$0; print l}$0~/^[0-9]/{print l;print $0}' \
    /$OUTPUT_DIR/tcpdump_${TS}.tmp > /$OUTPUT_DIR/tcpdump_${TS}.in
  rm /$OUTPUT_DIR/tcpdump_${TS}.tmp
done

for i in $(ls $OUTPUT_DIR/tcpdump_*.in);do
  echo "parse $OUTPUT_DIR/tcpdump_${TS}.out through $PYTHON_TCPDUMP_ANALYSIS"
  /usr/bin/python $PYTHON_TCPDUMP_ANALYSIS /$OUTPUT_DIR/tcpdump_${TS}.in > \
    /$OUTPUT_DIR/tcpdump_${TS}.out
done