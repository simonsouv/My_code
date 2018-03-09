rem
rem SQL statement retuning queries running more than x seconds
rem the crriteria must be defined here : and last_call_et...
rem

column dur format a20
select sid, serial#, username,
to_char(sysdate-last_call_et/24/60/60,'hh24:mi:ss') started,
trunc(last_call_et/60) || ' mins, ' || mod(last_call_et,60) ||
' secs' dur,
(select sql_text from v$sql where address = sql_address ) sql_text
from v$session
where username is not null
and last_call_et >= 0
and status = 'ACTIVE'
/

