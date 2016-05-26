#!/bin/bash
#set -x

# this script generates an output files containing the number of free pages in the logsegment for a given database -- so it works only on sybase
# the output is in the format <timestamp> | <number of free pages>
# user must provide dataserver_name, database_name, user_name, password and the sampling frequence
# the output file is generated under /tmp. The filename pattern is <dataserver_name>_<dataserver>_<random_number>.log
# data can the be graphed in any tool (excel / python / gnuplot / elk)

function usage {
  echo 'invalid number of arguments'
  echo 'script syntax: ./get_sybase_log_usage.sh <SYBASE_DATA_SERVER> <SYBASE_DATABASE> <SYBASE_LOGIN> <SYBASE_PASSWORD> <SLEEP_TIME_IN_SECONDS>'
}

#
# MAIN
#
DSERVER=$1
DBASE=$2
DUSER=$3
DPASSWD=$4
WAIT_TIME=$5
OUTPUT=/tmp/${DSERVER}_${DBASE}_$(date +%Y%m%d_%H%M%S)_${RANDOM}.log

# test the number of arguments
if [ $# -ne 5 ]; then
  usage
  exit 1
fi

# test the connection to the dataserver
isql -b -U ${DUSER} -P ${DPASSWD} -S ${DSERVER} -w300 << LAFIN
exit
LAFIN

if [ $? -ne 0 ]; then
  echo "problem connecting to the database ${DBASE}@${DSERVER} with user ${DUSER}"
  exit 2
fi

#create a temp sql file containing the sql statements to test the existence of the db
echo 'set nocount on' > /tmp/sql.sql
echo 'go' >> /tmp/sql.sql
echo "if exists(select 1 from sysdatabases where name='${DBASE}') print 'OKOK'" >> /tmp/sql.sql
echo 'go' >> /tmp/sql.sql
echo 'exit' >> /tmp/sql.sql

# test the existence of the database
isql -b -U ${DUSER} -P ${DPASSWD} -S ${DSERVER} -w300 -i /tmp/sql.sql | /usr/xpg4/bin/grep -q 'OKOK'

if [ $? -ne 0 ]; then
  echo "Database ${DBASE} does not exist"
  exit 3
fi

#create a temp sql file containing the sql statements to get the logsegment usage
echo 'set nocount on' > /tmp/sql2.sql
echo 'go' >> /tmp/sql2.sql
echo "select convert(varchar(18),getdate(),21)+'|'+convert(varchar(10),lct_admin('logsegment_freepages',db_id('${DBASE}')))" >> /tmp/sql2.sql
echo 'go' >> /tmp/sql2.sql
echo 'exit' >> /tmp/sql2.sql

# get the logsegment usage
echo "get log segment free space. Output is saved in ${OUTPUT}"
echo "sampling is done every ${WAIT_TIME}"
echo 'timestamp|logsegment_free_pages' > ${OUTPUT}
while (true);do
  echo 'sampling...'
  isql -b -U ${DUSER} -P ${DPASSWD} -S ${DSERVER} -w300 -i /tmp/sql2.sql >> ${OUTPUT}
  sleep ${WAIT_TIME}
done
