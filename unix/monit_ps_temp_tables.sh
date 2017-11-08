#!/usr/bin/bash
#set -x

# shell script that will
#    launch a process script
#    check that the temporary tables are removed
# the script must be copied in the folder containing
#    ps .xml files
#    answer files
# the script relies on servers_config.txt file containing the 
#    list of servers part of this env and respective app_dir
# WARNING the script is working
#    if you can ssh to remote host without password

OS=`uname`
case $OS in
  'Linux')
    AWK=/usr/bin/gawk
    ;;
  'SunOS')
    AWK=/usr/bin/nawk
    ;;
esac

## FUNCTIONS ##
exit_on_error (){
  printf "$1"
  exit 1
}

check_temp_tables(){
  TMP_FILE=/tmp/edcrfv.txt
  INPUT_SQL=/tmp/count_temp_tables_${2}_${3}.sql
  OUTPUT_SQL=${INPUT_SQL/sql/out}

  [ -e ${TMP_FILE} ] && rm ${TMP_FILE}
  [ -e ${INPUT_SQL} ] && rm ${INPUT_SQL}
  [ -e ${OUTPUT_SQL} ] && rm ${OUTPUT_SQL}

  # generate temp txt file that will contain the 'name like' syntax
  $AWK -v q="'" '$0~/successfully created on host/ {gsub("NPID:","",$7);gsub(/[()]/,"",$NF);print "name like " q $NF "#" $7 "#Z%TMP" q " or"}' $1 > $TMP_FILE

  # number of lines in file
  LINE_NUMBER=`wc -l $TMP_FILE | awk '{print $1}' `
  
  $AWK -v q="'" -v tot=$LINE_NUMBER 'BEGIN {print"set nocount on\ngo\nuse tempdb\ngo\nselect count(*) from sysobjects where type = " q "U" q " and ("} {if (NR != tot){print} else{print $1, $2, $3} } END{print ")\ngo\n"}' $TMP_FILE > $INPUT_SQL
  
  # execute the sql file generated
  isql -S $4 -U $5 -P $6 -D tempdb -w300 -i ${INPUT_SQL} -o ${OUTPUT_SQL}
  
  printf "%-18s %s\n" "Date" "`date '+%Y/%m/%d %HH:%MM:%SS'`"
  printf "%-18s %s\n" "temp tables #" "`tail -1  ${OUTPUT_SQL} | tr -d ' '`"
  # if output file is empty then temp tables were removed
  #[ -s ${OUTPUT_SQL} ] && printf "check file %s for any remaining temp tables" "${OUTPUT_SQL}" || printf "all temp tables removed\n"
}

## MAIN ##

# modify the content of the file servers_config.txt according to your environment
SERVERS_LIST='servers_config.txt'

# modify PATH if program 'isql' cannot be called
PATH=$PATH:

# get current hostname, necessary to know where the processing script is actually executed
CURRENT_SERVER=`hostname`

# get database information
DS=`grep DbServerOrServiceName ../fs/public/mxres/common/dbconfig/dbsource.mxres | sed 's/<\/*DbServerOrServiceName>//g' | sed 's/  *//g'`
DBUSER='INSTAL'
DBPWD='INSTALL'

[ $# -ne '1' ] && exit_on_error "You must provide the processing script.\nExample: ./launch_ps_check_temp_tables.sh eups_aud_cnt_ps\n"

#printf "Execute processing script %s\n" "$1"
#./xmlrequestscriptshell.sh $1

#[ $? -ne 0 ] && exit_on_error "ERROR in the execution of the procecssing script $1\n"

# check if answer file exists and is not empty
[ -e "${1}_log.xml" ] || exit_on_error "file ${1}_log.xml does not exist\n"
[ -s "${1}_log.xml" ] || exit_on_error "file ${1}_log.xml is empty\n"


PS_PID=`cat ${1}_log.xml | cut -d',' -f3 | sed 's/ NPID=//g'`
[ -z ${PS_PID} ] && exit_on_error "Cannot find PID in the file ${1}_log.xml\n"

PS_HOST=`cat ${1}_log.xml | cut -d',' -f6 | cut -d'<' -f1 | sed 's/ host=//g' `
[ -z ${PS_HOST} ] && exit_on_error "Cannot find Hostname in the file ${1}_log.xml\n"

# get application dir location where the processing script was executed
PS_APP_DIR=`grep ${PS_HOST} ${SERVERS_LIST} | cut -d';' -f 2`
[ -z ${PS_APP_DIR} ] && exit_on_error "Cannot find Hostname in the file ${SERVERS_LIST}\n"

if [ $CURRENT_SERVER == $PS_HOST ]; then
  PS_LOG_FILE=`find ${PS_APP_DIR}/logs -name "scanner_client\.${PS_PID}\.log"`  
  FILE_TO_ANALYZE=$PS_LOG_FILE
else 
  # the processing script was executed on a remote server
  # need to ssh to the target host get the corresponding log file
  PS_LOG_FILE=`ssh $PS_HOST "find ${PS_APP_DIR}/logs -name \"scanner_client\.${PS_PID}\.log\" "`
  ssh $PS_HOST "cat $PS_LOG_FILE" > /tmp/`basename $PS_LOG_FILE`
  FILE_TO_ANALYZE=/tmp/`basename $PS_LOG_FILE`
fi

printf "%-18s %s\n" "processing script" "$1"
printf "%-18s %s\n" "pid" "$PS_PID"
printf "%-18s %s\n" "hostname" "$PS_HOST"
printf "%-18s %s\n" "application dir" "$PS_APP_DIR"
printf "%-18s %s\n" "log file" "$PS_LOG_FILE"

check_temp_tables "$FILE_TO_ANALYZE" "$PS_HOST" "$PS_PID" "$DS" "$DBUSER" "$DBPWD"
