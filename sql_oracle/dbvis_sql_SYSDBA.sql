select s.sql_id, s.sql_text from V$SQL s where s.sql_text like 'select count (*) from ( select distinct B.M_OUTPUT as DatamartTable_Name';
-- ***
-- list information about running SQL
-- **
SELECT /*+ gather_plan_statistics */
OSUSER, SERIAL#, SID, executions,sql.SQL_ID ,sql.child_number, last_active_time, elapsed_time, SQL_TEXT
FROM V$SESSION sess JOIN V$SQL sql
on  (sess.SQL_ID = sql.SQL_ID)
where sess.SID=1901; -- and sess.STATUS = 'ACTIVE' -- retrieve information about running SQL statements
select plan_table_output
from   v$sql s,
       table(dbms_xplan.display_cursor(s.sql_id, s.child_number,'typical')) t
where  s.sql_id = 'fubw4zpx2nxfg'; --get the execution plan for a SQL identifier retrieved above
-- **************************************
-- list the running SQL and their runTime
-- **************************************
SELECT nvl(ses.username,'ORACLE PROC')||' ('||ses.sid||')' USERNAME,
       SID,MACHINE,
       REPLACE(SQL.SQL_TEXT,CHR(10),'') STMT,
       ltrim(to_char(floor(SES.LAST_CALL_ET/3600), '09')) || ':'
       || ltrim(to_char(floor(mod(SES.LAST_CALL_ET, 3600)/60), '09')) || ':'
       || ltrim(to_char(mod(SES.LAST_CALL_ET, 60), '09'))    RUNT
  FROM V$SESSION SES,
       V$SQLtext_with_newlines SQL
 where SES.STATUS = 'ACTIVE'
   and SES.USERNAME is not null
   and SES.SQL_ADDRESS    = SQL.ADDRESS
   and SES.SQL_HASH_VALUE = SQL.HASH_VALUE
   and Ses.AUDSID <> userenv('SESSIONID')
 order by runt desc, 1,sql.piece;

select last_update_time, username,opname,target_desc,sofar,totalwork,message from V$SESSION_LONGOPS where username='VANILLA_39_MX' order by LAST_UPDATE_TIME desc;
-- ******************************************************************
-- list blocking and blocked session (http://www.orafaq.com/node/854)
-- ******************************************************************
select * from V$LOCK; -- Note the BLOCK column. If a session holds a lock that's blocking another session, BLOCK=1. Further, you can tell which session is being blocked by comparing the values in ID1 and ID2. The blocked session will have the same values in ID1 and ID2 as the blocking session, and, since it is requesting a lock it's unable to get, it will have REQUEST > 0

select l1.sid, ' IS BLOCKING ', l2.sid
from v$lock l1, v$lock l2
where l1.block =1 and l2.request > 0 and l1.id1=l2.id1 and l1.id2=l2.id2; -- detect blocking and blocked session

select s1.username || '@' || s1.machine || ' ( SID=' || s1.sid || '/ LockMode= ' ||
case l1.lmode when 0 then 'none' when 1 then 'null' when 2 then 'rows-s(SS)' when 3 then 'row-x(SX)' when 4 then 'share(S)' when 5 then 's/row-x(SSX)' when 6 then 'exclusive(X)' end || ';RequestMode= ' ||
case l1.request when 0 then 'none' when 1 then 'null' when 2 then 'rows-s(SS)' when 3 then 'row-x(SX)' when 4 then 'share(S)' when 5 then 's/row-x(SSX)' when 6 then 'exclusive(X)' end ||
' )  is blocking ' || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || '/ LockMode= ' ||
case l2.lmode when 0 then 'none' when 1 then 'null' when 2 then 'rows-s(SS)' when 3 then 'row-x(SX)' when 4 then 'share(S)' when 5 then 's/row-x(SSX)' when 6 then 'exclusive(X)' end || ';RequestMode= ' ||
case l2.request when 0 then 'none' when 1 then 'null' when 2 then 'rows-s(SS)' when 3 then 'row-x(SX)' when 4 then 'share(S)' when 5 then 's/row-x(SSX)' when 6 then 'exclusive(X)' end ||
' ) ' as blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 and l2.request > 0 and l1.id1 = l2.id1 and l2.id2 = l2.id2; -- same query with session and lock information

select do.owner, do.object_name, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#, dbms_rowid.rowid_create ( 1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# ) as ROW_ID
from v$session s, dba_objects do
where sid=590 and s.ROW_WAIT_OBJ# = do.OBJECT_ID; -- identify object locked

select * from MXPRD_JAN16.tstlock where rowid = 'AADVr+ACQAAAACPAAA'; -- schema / table and rowid are retrieved from the query above (1st, 2nd and last column)

select
   sql_id,
   sql_text
from
   v$sqlarea
where
   upper(sql_text) like '%ACT_BAT_DBF%'
order by disk_reads desc;
select * from table(dbms_xplan.display_awr('4vj1jmvjuwxxh'));

select * from DBA_TABLESPACES;
