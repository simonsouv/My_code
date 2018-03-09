
DBUSER=
DBPASSWD=
DBNAME=
if [ $# -eq 1 ]
then
	SCHEMA=$1
else
	echo "usage: $0 <SCHEMA_NAME>"
	exit 1
fi
killSession=/tmp/killSession-`date +%m%d%y%H%M%S`.sql
sqlplus $DBUSER/$DBPASSWD@$DBNAME << EOF |grep ALTER > $killSession
set ECHO OFF
set HEAD OFF
SET COLSEP  | 
select 'ALTER SYSTEM KILL SESSION '''|| sid ||','|| serial# ||''';' from v\$session where username = '$SCHEMA'; 
EOF
sqlplus $DBUSER/$DBPASSWD@$DBNAME << EOF 
set HEAD OFF
@$killSession
EOF
/bin/rm $killSession

