select @@version;
select db_name();
select db_id();
select * from syslisteners;
sp_who;
sp_lock null,null,1;
sp_helpdb;
sp_help sysdevices;
sp_helpindex ;
sp_helprotect SIMON;
sp_spaceusage 'display','tranlog','syslogs';
sp_HelpIndex_sg;
sp_configure 'parallel degree';

-- GET CAGHE INFORMATION
sp_cacheconfig;
sp_helpcache;
sp_logiosize 'all';

-- GET OBJECT INFORMATION
select name,id from sysobjects where name like '%SIMON%';
select object_name(1737782963);
select db_id();

-- DBCC COMMAND
dbcc traceon(3604);
dbcc sqltext(883);
dbcc listoam(2,925968947,0);
dbcc page(2,16532,0);
dbcc pglinkage(2,16473,0,2,0,1);

-- GET ASE SYSTEM WIDE INFORMATION
select StatisticID, Statistic, InstanceID, EngineNumber, Sample, SteadyState, Avg_1min, Avg_5min, Avg_15min, Peak, Max_1min, Max_5min, Max_15min from master..monSysLoad; -- check especially Statistic 'run queue length'

-- GET PROCEES INFORMATION
select * from master..monProcess where SPID=522; -- general information about a process
select * from master..monProcessActivity where SPID=522;
select * from master..monProcessStatement where SPID=522;
select p.Login,p.Application,p.Command,pa.ULCBytesWritten, pa.ULCFlushes, pa.ULCFlushFull,pa.ULCMaxUsage 
from master..monProcess p join master..monProcessActivity pa on p.SPID = pa.SPID and p.InstanceID = pa.InstanceID and p.KPID = pa.KPID
where p.SPID=522; -- query to get ULC information about a SPID

-- WAIT EVENTS INFOS
select top 20 T2.Description Event_Desc, T3.Description Class_Desc, T1.* 
from master..monSysWaits T1 join master..monWaitEventInfo T2 on T1.WaitEventID = T2.WaitEventID 
                            join master..monWaitClassInfo T3 on T2.WaitClassID = T3.WaitClassID 
order by WaitTime desc; -- get System wide Waits events
select T1.SPID, T1.InstanceID ,T1.KPID, T2.Waits, T2.WaitTime, T3.Description Event_Desc, T4.Description Class_Desc
from master..monProcess T1 join master..monProcessWaits T2 on T1.SPID = T2.SPID and T1.InstanceID = T2.InstanceID and T1.KPID = T2.KPID 
                           join master..monWaitEventInfo T3 on T2.WaitEventID = T3.WaitEventID
                           join monWaitClassInfo T4 on T3.WaitClassID = T4.WaitClassID
where T1.SPID = 519; -- get process Waits events

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

-- GET IO INFORMATION
select sysDv.name, sysU.lstart, sysU.size, sysU.vstart, sysU.segmap, sysU.vdevno, monDevI.Reads, monDevI.APFReads, monDevI.Writes, monDevI.IOTime--, monIO.IOs, monIO.IOTime, monIO.IOType
from master..sysdatabases sysD join master..sysusages sysU on sysD.dbid = sysU.dbid 
                               join master..sysdevices sysDv on sysU.vdevno = sysDv.vdevno 
                               join master..monDeviceSpaceUsage monDevS on sysDv.vdevno = monDevS.VDevNo
                               join master..monDeviceIO monDevI on monDevS.LogicalName = monDevI.LogicalName
                               --join master..monIOQueue monIO on monDevI.LogicalName = monIO.LogicalName
where sysD.name = 'BBVA_CONVERSION_DEBUG' order by sysU.lstart;
select * from master..monIOQueue;

-- GET THE LOG SEMAPHORE CONTENTION
select DBID, DBName, AppendLogRequests, AppendLogWaits, (convert(numeric(10,0),AppendLogWaits)/convert(numeric(10,0),AppendLogRequests))*100 as 'LogContention%'  
from master..monOpenDatabases;

-- GET TABLE SIZE
select O.name, O.loginame, space_used_kb=(used_pages(db_id(),O.id)*4) --space_used_kb contains space used by data and index
from sysobjects O
where O.type = 'U'
order by space_used_kb desc;