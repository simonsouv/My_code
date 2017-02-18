#!/usr/bin/bash
#set -x
# args list Dataserver Database

function usage {
 printf "## syntax error ##\n"
 printf "usage:\t update_all_statistics_syb15.sh <dataserver name> <database name>\n"
 printf "ex:\t update_all_statistics_syb15.sh MX626ZN MX\n"
 exit -1
}

if [[ $# -ne 2 ]]; then
  usage
fi

DS=$1
DB=$2
MX_USER='INSTAL'
MX_PWD='INSTALL'
SA_USER='sa'
SA_PWD=''
TMP_SQL='/tmp/tmp_table_list.sql'
TMP_SQL_LOG='/tmp/tmp_table_list.txt'
TMP_SQL_CONN='/tmp/tmp_sql_conn.sql'
TMP_SQL_CONN_LOG='/tmp/tmp_sql_conn.log'
PARALLEL_LEVEL=4
TMP_SQL_UPD_STATS='/tmp/upd_stat.sql'
SLEEP_TIME=30


[[ -e ${TMP_SQL_CONN} ]] && rm ${TMP_SQL_CONN}
[[ -e ${TMP_SQL_CONN_LOG} ]] && rm ${TMP_SQL_CONN_LOG}


echo 'exit' > ${TMP_SQL_CONN}

#test database connection
isql -U ${MX_USER} -P ${MX_PWD} -S ${DS} -D ${DB} -i ${TMP_SQL_CONN} -o ${TMP_SQL_CONN_LOG} >/dev/null
if [[ $? -ne 0 ]] || [[ -s ${TMP_SQL_CONN_LOG} ]]; then
  printf "Cannot connect to database %s on dataserver %s, please check the information provided\n" "${DB}" "${DS}"
  exit -2
fi

#remove temporary file if exists
[[ -e ${TMP_SQL_LOG} ]] && rm ${TMP_SQL_LOG}
[[ -e ${TMP_SQL} ]] && rm ${TMP_SQL}

#generate the sql to retrieve the table list
printf "set nocount on \ngo\n" > ${TMP_SQL}
echo 'select convert(varchar(30),o.name) AS table_name,row_count(db_id(), o.id) AS row_count,data_pages(db_id(), o.id, 0) AS pages, data_pages(db_id(), o.id, 0) * (@@maxpagesize/1024) AS kbs' >> ${TMP_SQL}
echo 'from sysobjects o where type = "U" order by kbs desc' >> ${TMP_SQL}
echo 'go' >> ${TMP_SQL}

#execute the sql
printf "%s:\t execute sql to retrieve table list\n" "$(date +%y/%m/%d@%H:%M:%S)"
isql -U ${MX_USER} -P ${MX_PWD} -S ${DS} -D ${DB} -i ${TMP_SQL} -o ${TMP_SQL_LOG} -b

#remove tmps sql that will contain the update stats
COMPTEUR=1
while [[ ${COMPTEUR} -le ${PARALLEL_LEVEL} ]]; do
  [[ -e ${TMP_SQL_UPD_STATS/.sql/${COMPTEUR}.sql} ]] && rm ${TMP_SQL_UPD_STATS/.sql/${COMPTEUR}.sql}
  ((COMPTEUR+=1))
done

COMPTEUR=1
#generate the sql that will contain the update stats
printf "%s:\t generate %s tmp files containing the update index statistics statement\n" "$(date +%y/%m/%d@%H:%M:%S)" "${PARALLEL_LEVEL}"
for table_name in $(awk '{print $1}' ${TMP_SQL_LOG});do 
  printf "print 'update index statistics on table %s'\ngo\nupdate index statistics %s\ngo\n" "${table_name}" "${table_name}" >> ${TMP_SQL_UPD_STATS/.sql/${COMPTEUR}.sql}
  ((COMPTEUR+=1))
  [[ ${COMPTEUR} -gt ${PARALLEL_LEVEL} ]] && ((COMPTEUR=1))
done

#launch the update stats
printf "%s:\t Starting update index statistics execution on database %s@%s \n" "$(date +%y/%m/%d@%H:%M:%S)" "${DB}" "${DS}"
for file_name in $(ls ${TMP_SQL_UPD_STATS/.sql/*});do
  #ls ${file_name} > /dev/null 2>&1 &
  isql -U ${MX_USER} -P ${MX_PWD} -S ${DS} -D ${DB} -i ${file_name} -o ${file_name/.sql/.log} &
  procs[$!]=$! #procs[] is an array containing the pid of isql commands
  printf "update statistics launched, check log file %s\n" "${file_name/.sql/.log}"
done
#looping to check if process are still running
RUNNING=1
while [[ ${RUNNING} -eq 1 ]];do
  printf "check for running process every %ss\n" "${SLEEP_TIME}"
  for i in $(echo ${procs[@]});do #check for each pid if it's still running
    [[ $(ps -ef | grep ${i} | grep -v grep | wc -l) -lt 1 ]] && unset procs[${i}] #pid is not running anymore, remove it from procs array
  done
  [[ ${#procs[@]} -eq 0 ]] && RUNNING=0 #procs array is empty, no more isql is running. We can stop
  [[ ${RUNNING} -eq 1 ]] && sleep ${SLEEP_TIME}
done
printf "%s:\t UPDATE STATISTICS FINISHED\n" "$(date +%y/%m/%d@%H:%M:%S)"
