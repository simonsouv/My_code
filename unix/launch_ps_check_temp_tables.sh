#!/usr/bin/bash
#set -x

# shell script that will
#  retrieve the processing script NPID in order to count: 
#    the number of temp tables created
# the script must be copied in the folder containing
#    ps .xml files
#    log files
# the script relies on servers_config.txt file containing: 
#    list of servers part of this env and respective app_dir
# WARNING the script is working:
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
  INPUT_SQL=/tmp/check_temp_tables_${2}_${3}.sql
  OUTPUT_SQL=${INPUT_SQL/sql/out}

  [ -e ${INPUT_SQL} ] && rm ${INPUT_SQL}
  [ -e ${OUTPUT_SQL} ] && rm ${OUTPUT_SQL}

  # generate temp sql file contains select statement
  # to check temp tables still exist or not
  $AWK -v q="'" '$0~/successfully created on host/ {gsub("NPID:","",$7);gsub(/[()]/,"",$NF);print "if exists (select 1 from sysobjects where name like " q $NF "#" $7 "#Z%TMP" q ") print " q "remaining temp tables for PID " $7 " executed on host " $NF q "\ngo"}' $1 > $INPUT_SQL

  # execute the sql file generated
  isql -S $4 -U $5 -P $6 -D tempdb -w300 -i ${INPUT_SQL} -o ${OUTPUT_SQL}

  # if output file is empty then temp tables were removed
  [ -s ${OUTPUT_SQL} ] && printf "check file %s for any remaining temp tables" "${OUTPUT_SQL}" || printf "all temp tables removed\n"
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
[ -e "${1}_answer.xml" ] || exit_on_error "file ${1}_answer.xml does not exist\n"
[ -s "${1}_answer.xml" ] || exit_on_error "file ${1}_answer.xml is empty\n"

# get different infromaation from the answer file
STATUS=`xmllint -format ${1}_answer.xml | grep Status | sed 's/<\/*Status>//g' | sed 's/  *//g' `
[ -z ${STATUS} ] && exit_on_error "Cannot find Status in the file ${1}_answer.xml\n"

PS_PID=`xmllint -format ${1}_answer.xml | grep PID | sed 's/<\/*PID>//g' | sed 's/  *//g' `
[ -z ${PS_PID} ] && exit_on_error "Cannot find PID in the file ${1}_answer.xml\n"

PS_HOST=`xmllint -format ${1}_answer.xml | $AWK '$0~/PID/ {getline;gsub(/<\/*HostName>/,"",$1);print $1}' `
[ -z ${PS_HOST} ] && exit_on_error "Cannot find Hostname in the file ${1}_answer.xml\n"

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

printf "%-20s %s\n" "processing script" "$1"
printf "%-20s %s\n" "status" "$STATUS"
printf "%-20s %s\n" "pid" "$PS_PID"
printf "%-20s %s\n" "hostname" "$PS_HOST"
printf "%-20s %s\n" "application dir" "$PS_APP_DIR"
printf "%-20s %s\n" "log file" "$PS_LOG_FILE"

check_temp_tables "$FILE_TO_ANALYZE" "$PS_HOST" "$PS_PID" "$DS" "$DBUSER" "$DBPWD"
