select @@version;
select db_name();
select db_id();
sp_who;
sp_lock null,null,1;
sp_helpdb;
sp_help SIMON;
sp_helpindex ;
sp_helprotect SIMON;
sp_spaceusage 'display','tranlog','syslogs';
sp_HelpIndex_sg;
sp_configure 'parallel degree';

-- get cache configuration
sp_cacheconfig;
sp_helpcache;
sp_logiosize 'all';

-- get object information
select name,id from sysobjects where name like '%SIMON%';
select object_name(1737782963);
select db_id();

-- dbcc command
dbcc traceon(3604);
dbcc sqltext(883);
dbcc listoam(2,925968947,0);
dbcc page(2,16532,0);
dbcc pglinkage(2,16473,0,2,0,1);

-- get ASE system wide information
select StatisticID, Statistic, InstanceID, EngineNumber, Sample, SteadyState, Avg_1min, Avg_5min, Avg_15min, Peak, Max_1min, Max_5min, Max_15min from master..monSysLoad; -- check especially Statistic 'run queue length'

-- get process information
select * from master..monProcess where SPID=522; -- general information about a process
select * from master..monProcessActivity where SPID=522;
select * from master..monProcessStatement where SPID=522;
select p.Login,p.Application,p.Command,pa.ULCBytesWritten, pa.ULCFlushes, pa.ULCFlushFull,pa.ULCMaxUsage -- query to get ULC information about a SPID
from master..monProcess p join master..monProcessActivity pa on p.SPID = pa.SPID and p.InstanceID = pa.InstanceID and p.KPID = pa.KPID
where p.SPID=522;

-- get System wide Waits events
select T2.Description, T1.* from master..monSysWaits T1 join master..monWaitEventInfo T2 on T1.WaitEventID = T2.WaitEventID order by WaitTime desc;

-- query to view the activity of the checkpoint and HKW processes
select T2.Command,T2.Priority,T1.CPUTime, T1.WaitTime, T1.PhysicalWrites,T1.PagesWritten, convert(numeric(10,0),T1.PagesWritten)/convert(numeric(10,0),T1.PhysicalWrites) as Avg_Pages_per_Writes
from master..monProcessActivity T1 join master..monProcess T2 on T1.SPID=T2.SPID and T1.InstanceID = T2.InstanceID and T1.KPID = T2.KPID 
where T2.Command in ('CHECKPOINT SLEEP','HK WASH');
-- query to view the wait event for checkpoint and HKW processes
select T2.Command,T2.Priority,T2.SPID, T3.WaitEventID,T3.Description,T1.Waits, T1.WaitTime,convert(numeric(10,0),T1.WaitTime)/convert(numeric(10,0),T1.Waits), T4.PhysicalWrites 
from master..monProcessWaits T1 join master..monProcess T2 on T1.SPID=T2.SPID and T1.InstanceID = T2.InstanceID and T1.KPID = T2.KPID
                                join master..monWaitEventInfo T3 on T1.WaitEventID = T3.WaitEventID 
                                join master..monProcessActivity T4 on T1.SPID = T4.SPID and T1.InstanceID = T4.InstanceID and T1.KPID = T4.KPID
where T2.Command in ('CHECKPOINT SLEEP','HK WASH') and T1.Waits > 100 or T1.WaitTime > 1000;

-- query to view get some idea about the HK GC activities
select EngineNumber, HkgcMaxQSize, HkgcPendingItems, HkgcHWMItems, HkgcOverflows from master..monEngine; -- pre engine
select top 25 DBName, ObjectName, IndexID, LogicalReads, PhysicalWrites, PagesWritten, RowsInserted, RowsDeleted, RowsUpdated  HkgcRequests, HkgcPending, HkgcOverflows 
from master..monOpenObjectActivity order by HkgcPending desc; -- per table

-- get statistics information
select * from sysstatistics where id = (1596361532);