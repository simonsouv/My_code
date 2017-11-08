select @@version;
select db_name();
select db_id();
select getdate();
select @@servername,* from master..syslisteners;
kill 403;
setuser 'MUREXDB';

sp_transactions;
sp_configure 'enable housekeeper';,131072;
sp_help sysusers;
sp_helpdb;
sp_helpindex RT_INDEX_DBF;
sp_helprotect SIMON;
sp_helpuser;
sp_lock 301,null,@verbose=1;
sp_spaceusage 'display','tranlog','syslogs';
sp_who;
sp_MxWho;
sp_MxDatabase;
sp_flushstats;
sp_object_stats '00:05:00';
sp_showplan 496, null, null, null;

drop database P7_TMP_MLC;
create database BBVA_ENV_LIKE_DM on MUREXFS60=1500 for LOAD;
load database BBVA_ENV_LIKE_DM from 'compress::/net/fs8612/alloc0001557/dump/FEB_2.11_To_Convert/DM/DM_211.cmp';
dump database BBVA_ENV_LIKE_DM to 'compress::/net/mx4120vm//data1/fromBBVA/LAB16_CONVERSION/LAB16_CONVERSION//DM.cmp';
online database BBVA_ENV_LIKE_DM;

sp_dboption 'MIG_MX','single',false;
checkpoint MIG_MX;

sp_monitorconfig 'all';
sp_monitor connection, diskio;

sp_audit 'alter', 'all','MIG_MX','off';
sp_audit 'bcp', 'all', 'MIG_MX','';
sp_audit 'cmdtext', 'INSTAL','all','on';
sp_audit 'create', 'all', 'MIG_MX', 'on';
sp_audit 'delete', 'all', 'DEFAULT TABLE', 'off';
sp_audit 'drop', 'all', 'MIG_MX', 'on';
sp_audit'grant', 'all', 'MIG_MX', 'on';
sp_audit 'insert', 'all', 'DEFAULT TABLE', 'off';
sp_audit 'select', 'all', 'simon2', 'on';
sp_audit 'table_access', 'INSTAL','all','on';
sp_audit 'truncate', 'all', 'MIG_MX', 'on';
sp_audit 'update', 'all', 'simon2', 'on';
sp_audit 'view_access', 'INSTAL', 'all', 'on';
sp_audit restart;
sp_displayaudit;


-- QUERY ANALYZER flags
setuser 'MUREXDB';
set statistics time,io,plancost on;
set showplan on;
set statement_cache off;
dbcc traceon(3604);
dbcc traceon(3604,9528); -- format the output of plancost
dbcc cacheremove ('BBVA_PROD_REF','DPI_ID_DBF');
set option show_missing_stats on;

update statistics TRN_HDR_DBF(M_PURPOSE);

-- GET CAGHE INFORMATION
sp_cacheconfig;
sp_helpcache;
sp_logiosize 'all';
sp_showplan 332,NULL,NULL,NULL;

-- GET OBJECT INFORMATION
select name,id,uid,type,crdate from sysobjects where name like '%SST%';
select name,id,uid,type,crdate from sysobjects where type = 'U';
--select 'select "'+name+'", count(*) from '+name'+' union all' from sysobjects where name like 'PS_%_E' order by name;
select object_name(1322288214);
select * from sysindexes where name like '%INDEX%ND0%';
select db_id();

-- DBCC COMMAND
dbcc traceon(3604);
dbcc sqltext(883);
dbcc listoam(2,925968947,0);
dbcc page(2,16532,0);
dbcc pglinkage(2,16473,0,2,0,1);

-- GET ASE SYSTEM WIDE INFORMATION
select StatisticID, Statistic, InstanceID, EngineNumber, Sample, SteadyState, Avg_1min, Avg_5min, Avg_15min, Peak, Max_1min, Max_5min, Max_15min from master..monSysLoad; -- check especially Statistic 'run queue length'

-- GET PROCESS INFORMATION
select * from master..sysprocesses;
select spid, kpid,status,hostname,program_name,hostprocess,cmd,cpu,physical_io,blocked,dbid,uid,tran_name,time_blocked,network_pktsz from master..sysprocesses where spid in (17);
select * from master..monProcess where SPID=17; and KPID=1478164737; -- Provides detailed statistics about processes that are currently executing or waiting. Empty if the SPID does nothing
select * from master..monProcessActivity where SPID=332; and KPID=1478164737; -- Provides detailed statistics about process activity
select * from master..monProcessStatement where SPID=32 and KPID=1478164737; -- Provides information about the statement currently executing

select p.Login,p.Application,p.Command,pa.ULCBytesWritten, pa.ULCFlushes, pa.ULCFlushFull,pa.ULCMaxUsage from master..monProcess p join master..monProcessActivity pa on p.SPID = pa.SPID and p.InstanceID = pa.InstanceID and p.KPID = pa.KPID
where p.SPID=522; -- query to get ULC information about a SPID

-- GET LOCK INFORMATION
select * from monLocks where SPID=287 and KPID=708378906;

-- GET IO INFORMATION
select sysDv.name, sysU.lstart, sysU.size, sysU.vstart, sysU.segmap, sysU.vdevno
from master..sysdatabases sysD join master..sysusages sysU on sysD.dbid = sysU.dbid 
                               join master..sysdevices sysDv on sysU.vdevno = sysDv.vdevno 
                               join master..monDeviceSpaceUsage monDevS on sysDv.vdevno = monDevS.VDevNo
                               join master..monDeviceIO monDevI on monDevS.LogicalName = monDevI.LogicalName
where sysD.name = 'BBVA_CONVERSION_DEBUG' order by sysU.lstart; -- get database mapping

select LogicalName, Reads, APFReads, ReadTime, convert(numeric(10,0),ReadTime)/(Reads + APFReads) "Read_ms", 
    Writes, WriteTime, case Writes when 0 then 0 else convert(numeric(10,0),WriteTime)/Writes end "Writes_ms", DevSemaphoreRequests, DevSemaphoreWaits  
    from master..monDeviceIO monIO join master..sysdevices dev on monIO.LogicalName = dev.name 
    join (select distinct u.vdevno from master..sysusages u join master..sysdatabases d on d.dbid = u.dbid where d.name = 'TPK0002543_25895690') dev_used  on dev.vdevno = dev_used.vdevno; --IO speed information


-- WAIT EVENTS INFOS
select top 20 T2.Description Event_Desc, T3.Description Class_Desc, T1.WaitEventID, T1.WaitTime, T1.Waits, convert(numeric(10,0),WaitTime)/Waits "ms/Wait"
from master..monSysWaits T1 join master..monWaitEventInfo T2 on T1.WaitEventID = T2.WaitEventID 
                            join master..monWaitClassInfo T3 on T2.WaitClassID = T3.WaitClassID 
order by WaitTime desc; -- get System wide Waits events
select T1.SPID, T1.InstanceID ,T1.KPID, T2.Waits, T2.WaitTime, convert(numeric(10,0),T2.WaitTime)/T2.Waits "ms/Wait", T3.Description Event_Desc, T4.Description Class_Desc
from master..monProcess T1 join master..monProcessWaits T2 on T1.SPID = T2.SPID and T1.InstanceID = T2.InstanceID and T1.KPID = T2.KPID 
                           join master..monWaitEventInfo T3 on T2.WaitEventID = T3.WaitEventID
                           join master..monWaitClassInfo T4 on T3.WaitClassID = T4.WaitClassID
where T1.SPID in (select spid from master..sysprocesses where dbid in (select dbid from master..sysdatabases where name = 'TPK0002543_25895690')); -- get process Waits events

-- CHECKPOINT AND HKW PROCESSES INFORMATION
select T2.Command,T2.Priority,T1.CPUTime, T1.WaitTime, T1.PhysicalWrites,T1.PagesWritten, convert(numeric(10,0),T1.PagesWritten)/convert(numeric(10,0),T1.PhysicalWrites) as Avg_Pages_per_Writes
from master..monProcessActivity T1 join master..monProcess T2 on T1.SPID=T2.SPID and T1.InstanceID = T2.InstanceID and T1.KPID = T2.KPID 
where T2.Command in ('CHECKPOINT SLEEP','HK WASH'); -- query to view the activity of the checkpoint and HKW processes
select T2.Command,T2.Priority,T2.SPID, T3.WaitEventID,T3.Description,T1.Waits, T1.WaitTime,convert(numeric(10,0),T1.WaitTime)/convert(numeric(10,0),T1.Waits), T4.PhysicalWrites 
from master..monProcessWaits T1 join master..monProcess T2 on T1.SPID=T2.SPID and T1.InstanceID = T2.InstanceID and T1.KPID = T2.KPID
                                join master..monWaitEventInfo T3 on T1.WaitEventID = T3.WaitEventID 
                                join master..monProcessActivity T4 on T1.SPID = T4.SPID and T1.InstanceID = T4.InstanceID and T1.KPID = T4.KPID
where T2.Command in ('CHECKPOINT SLEEP','HK WASH') and T1.Waits > 100 or T1.WaitTime > 1000; -- query to view the wait event for checkpoint and HKW processes

-- GET HK GC ACTIVITIES INFORMATION
select EngineNumber, HkgcMaxQSize, HkgcPendingItems, HkgcHWMItems, HkgcOverflows from master..monEngine; -- pre engine
select top 25 DBName, ObjectName, IndexID, LogicalReads, PhysicalWrites, PagesWritten, RowsInserted, RowsDeleted, RowsUpdated  HkgcRequests, HkgcPending, HkgcOverflows 
from master..monOpenObjectActivity order by HkgcPending desc; -- per table
         
-- GET THE LOG SEMAPHORE
select DBID, DBName, AppendLogRequests, AppendLogWaits, (convert(numeric(10,0),AppendLogWaits)/convert(numeric(10,0),AppendLogRequests))*100 as 'LogContention%' from master..monOpenDatabases;

-- GET TABLE SIZE
---= sybase 15
select top 50 O.name, O.loginame, space_used_kb=(used_pages(db_id(),O.id)*4) --space_used_kb contains space used by data and index
from sysobjects O
where O.type = 'U'
order by space_used_kb desc;
---- sybase 12
select top 50 sysobjects.name, sysobjects.loginame, space_used_kb=sum(used_pgs(sysobjects.id, doampg, ioampg) * 4)
from sysindexes, sysobjects
where sysobjects.id > 100 and sysobjects.type = 'U'
and sysindexes.id = sysobjects.id
group by sysobjects.id, sysobjects.loginame
order by space_used_kb desc;
-- GET CACHE INFORMATION
select * from master..monCachedObject where DBName='tempdb' order by CachedKB desc;

-- MISC queries
select o.name,c.name
from sysobjects o join syscolumns c on o.id = c.id
where o.type='U' and c.name like '%FOLIO%';

select db.name,de.name,
case when substring(de.phyname,1,10)='/mx708zn2/' then 'memory' else 'disk' end 'dev_type'
from master..sysdatabases db join master..sysusages us on db.dbid = us.dbid
     join master..sysdevices de on us.vdevno = de.vdevno
where db.name not in ('master','model','tempdb','TEST','sybsystemdb','sybsystemprocs')
order by db.name, de.name;

select name, phyname from master..sysdevices where substring(phyname,1,10) = '/mx708zn2/' and name like 'MUREX%';
--- Audit table
truncate table sybsecurity..sysaudits_01;
select * from sybsecurity..sysaudits_01 where objname like '%MPY%';
select * from sybsecurity..sysaudits_01 where eventtime > '2017-05-12 17:06:39'; and eventtime < '2017-05-12 13:58:22';
select distinct spid from sybsecurity..sysaudits_01 where eventtime >= '2017-05-12 17:09:57' and eventtime <= '2017-05-12 17:10:08';
select  case when event = 62 then 'sel' when event = 18 then 'del' when event = 41 then 'ins' when event = 70 then 'upd' end 'action',event,spid, sequence, loginname,objname 
from sybsecurity..sysaudits_01 where event <> 92 and eventtime >= '2017-05-12 13:42:07' and eventtime <= '2017-05-12 13:42:34' 
group by event,spid, sequence, loginname,objname;
select case when event = 62 then 'sel' when event = 18 then 'del' when event = 41 then 'ins' when event = 70 then 'upd' end 'action',* 
from sybsecurity..sysaudits_01 where event = 92 and eventtime >= '2017-05-12 13:42:07' and eventtime <= '2017-05-12 13:42:34' and extrainfo like '%INSERT%';
select * from sybsecurity..sysaudits_01;


select convert(varchar(30),o.name) AS table_name,row_count(db_id(), o.id) AS row_count,data_pages(db_id(), o.id, 0) AS pages, data_pages(db_id(), o.id, 0) * (@@maxpagesize/1024) AS kbs
from sysobjects o where type = 'U' order by kbs desc;

select db_name()+'@'+@@servername as db, usr.uid, usr.name as owner, count(*)
from sysobjects obj join sysusers usr on obj.uid = usr.uid
where obj.type='U'
group by usr.name;

select name from sysobjects where uid = 5;

select db_name()+'@'+@@servername as db,obj.name as tabname, usr.name as owner 
from sysobjects obj join sysusers usr on obj.uid = usr.uid
where obj.type='U'; and (name like '%2540%' or name like '%2541%' or name like '%2542%' or name like '%2543%');
group by convert(char(15),name);