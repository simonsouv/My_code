#!/bin/bash

# shell script to extract data from sar binary file to text file
# the directory structure for the script to work must be
# /.../sar
# /.../extract_sar_to_csv.shell
# /.../inputs/  # folder containing sar binary files
# /.../outputs/  # folder containint the extract per category
# /.........../cpu
# /.........../memory
# /.........../swap
# /.........../disk
# /.........../network

function error_exit {
    echo "$1"   
    exit "${2:-1}"  ## Return a code specified by $2 or -1 by default.
}

INPUT='inputs'
OUTPUT='outputs'
# check if input directory exists and contains file
#if ! [ -d ${INPUT} ] || ! [ "$(ls -A ${INPUT})" ];then
#    echo "folder ${INPUT} does not exists or is empty"
#    exit 10
#fi

[ -d ${INPUT} ] || error_exit "folder ${INPUT} does not exist. Exit" "10"

#check output directories
[ -d ${OUTPUT}/_csv ] || mkdir -p ${OUTPUT}/_csv
[ -d ${OUTPUT}/cpu ] || mkdir -p ${OUTPUT}/cpu
[ -d ${OUTPUT}/memory ] || mkdir -p ${OUTPUT}/memory
[ -d ${OUTPUT}/swap ] || mkdir -p ${OUTPUT}/swap
[ -d ${OUTPUT}/disk ] || mkdir -p ${OUTPUT}/disk
[ -d ${OUTPUT}/network ] || mkdir -p ${OUTPUT}/network

touch ${OUTPUT}/cpu/test.txt || error_exit "cannot write under {OUTPUT}/cpu. Exit" "11"
touch ${OUTPUT}/memory/test.txt || error_exit "cannot write under {OUTPUT}/memory. Exit" "12"
touch ${OUTPUT}/swap/test.txt || error_exit "cannot write under {OUTPUT}/swap. Exit" "13"
touch ${OUTPUT}/disk/test.txt || error_exit "cannot write under {OUTPUT}/disk. Exit" "14"
touch ${OUTPUT}/network/test.txt || error_exit "cannot write under {OUTPUT}/network. Exit" "15"

for currentF in $(ls ${INPUT});do
    #ls -l ${INPUT}/$currentF
    OS=$(echo ${currentF} | cut -d_ -f2)
    printf "\nCurrent file: %s\n" "${currentF}"
    if [ $OS == 'SunOS' ];then
        echo 'retrieve cpu info'
        sar -u -f ${INPUT}/${currentF} > ${OUTPUT}/cpu/${currentF/.out/_cpu.out}
        echo 'retrieve runqueue info'
        sar -q -f ${INPUT}/${currentF} > ${OUTPUT}/cpu/${currentF/.out/_rq.out}
        echo 'retrieve memory info'
        sar -r -f ${INPUT}/${currentF} > ${OUTPUT}/memory/${currentF/.out/_mem.out}
        echo 'retrieve paging info'
        sar -g -f ${INPUT}/${currentF} > ${OUTPUT}/memory/${currentF/.out/_pg.out}
        echo 'retrieve swap info'
        sar -w -f ${INPUT}/${currentF} > ${OUTPUT}/swap/${currentF/.out/_sw.out}
        echo 'retrieve disk info'
        sar -d -f ${INPUT}/${currentF} > ${OUTPUT}/disk/${currentF/.out/_io.out}
    else
        echo 'retrieve cpu info'
        sar -P ALL -f ${INPUT}/${currentF} > ${OUTPUT}/cpu/${currentF/.out/_cpu.out}
        echo 'retrieve runqueue info'
        sar -q -f ${INPUT}/${currentF} > ${OUTPUT}/cpu/${currentF/.out/_rq.out}
        echo 'retrieve memory info'
        sar -r -f ${INPUT}/${currentF} > ${OUTPUT}/memory/${currentF/.out/_mem.out}
        echo 'retrieve paging info'
        sar -B -f ${INPUT}/${currentF} > ${OUTPUT}/memory/${currentF/.out/_pg.out}
        echo 'retrieve swap info'
        sar -S -f ${INPUT}/${currentF} > ${OUTPUT}/swap/${currentF/.out/_sw.out}
        echo 'retrieve disk info'
        sar -b -d -p -f ${INPUT}/${currentF} > ${OUTPUT}/disk/${currentF/.out/_io.out}
        echo 'retrieve network info'
        sar -n DEV -f ${INPUT}/${currentF} > ${OUTPUT}/network/${currentF/.out/_net.out}
    fi
    
done