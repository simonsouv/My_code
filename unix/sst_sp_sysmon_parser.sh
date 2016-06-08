#!/usr/bin/bash

# script calling recursively sst_sp_sysmon_parser.awk to analyse all sp_sysmon output file and generat a .csv file for analysis
# Assumption is that sp_sysmon output files are named in a way the sort by name reflect the sort by execution
# Assumption is that sp_sysmon output filename starts with sp_sysmon and with .txt extension

#############################
# Variables definition
#############################
SP_SYSMON_AWK_DIR=/cygdrive/d/Tmp/Santander
SP_SYSMON_AWK_FILE=${SP_SYSMON_AWK_DIR}/sst_sp_sysmon_parser.awk
SP_SYSMON_OUTPUT_FILES=/cygdrive/d/Tmp/Santander/sp_sysmon
RESULT_DIR=/cygdrive/d/Tmp/Santander
RESULT_FILE=${RESULT_DIR}/sp_sysmon_$(date +%Y%m%d_%H%M)_results.csv

#############################
# MAIN
#############################

if [ ! -r ${SP_SYSMON_AWK_FILE} ] ; then
  printf "\n%s is not readble, please check\n" "${SP_SYSMON_AWK_FILE}"
  exit 1
fi

if [ ! -d ${SP_SYSMON_OUTPUT_FILES} ] ; then
  printf "\n%s is not a directory, please check\n" "${SP_SYSMON_OUTPUT_FILES}"
  exit 1
fi

if [ ! -d ${RESULT_DIR} ] ; then
  printf "\n%s is not a directory, please check\n" "${RESULT_DIR}"
  exit 1
fi

touch ${RESULT_FILE}
if [ $? -ne 0 ] ; then
  printf "\ncannot write in %s, please check" "${RESULT_DIR}"
  exit 1
fi

#add header to result file
printf "date;time;dataserver;version;cpu_percent;io_percent;idle_percent;context switch cache search miss;context switch exceedint IO;context switch system disk;context switch Last log page write;context switch IO device contention;context switch other causes;housekeeper wash dirty;ulc flush by full ulc; ulc log semaphore wait; ulc semaphore wait;all caches hit; all caches miss; all caches buffer grabbed dirty; all caches large io denied pool too small;all caches large io effectiveness;def data cache hit;def data cache hit in wash;def data cache miss;def data cache large io denied pool too small;def data cache large io used;stmt cached;stmt found; stmt not found;stmt dropped;max outstanding io;io delay structure io;io delay server config; io delay engine config; io delay os config\n" > ${RESULT_FILE}

printf "\nStart parsing sp_sysmon output files saved under %s\n" "${SP_SYSMON_OUTPUT_FILES}"
for i in $(ls ${SP_SYSMON_OUTPUT_FILES}/sp_sysmon*.txt) ; do
  #echo $i
  awk -f ${SP_SYSMON_AWK_FILE} $i >> ${RESULT_FILE}
  #print "\n" >> ${RESULT_FILE}
done

printf "\nParsing done, please check result file %s" "${RESULT_FILE}"
