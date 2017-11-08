#!/bin/bash

# script to generate sar output file

SAR_OUTPUT=./inputs
SAR_COMM='sar -A'

# default is to execute sar for 1 hour every 20s
SAR_INT=20
SAR_COUNT=$(( 3600/${SAR_INT} ))
HOST=$(uname -n)
OS=$(uname -s)

#if [ `uname -s` == 'SunOS' ]; then
#    [[ `sar -A 2>/dev/null` ]] || SAR_COMM='sar -A'
#else
#    echo 'Linux'
#fi

#mkdir -p ${SAR_OUTPUT}
[ -d ${SAR_OUTPUT} ] || mkdir ${SAR_OUTPUT}

touch ${SAR_OUTPUT}/test.txt

if [ $? -ne 0 ];then
    echo "cannot write in ${SAR_OUTPUT}. exit"
    exit 2
fi

rm ${SAR_OUTPUT}/test.txt

echo "-- sar to run in a loop"
echo "-- each sar runs for 1h and generates and output file under ${SAR_OUTPUT}"
while(true);do
    CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
    echo "sar launched at ${CURRENT_DATE}"
    sar -A -o ${SAR_OUTPUT}/sar_${OS}_${HOST}_${CURRENT_DATE}.out ${SAR_INT} ${SAR_COUNT} >/dev/null 2>&1
done
