sselect * from master..syslisteners;
select @@servername;
select @@version;
select @@spid;
select db_name()as db_used , user_name();count(1) as total_rows from TRN_HDR_DBF;

sp_helpdb; MIG_MX; --COREPL_REP DYN_AUDIT_REP
sp_spaceused NPD_HDR_DBF, 1;
sp_helpindex TRN_HDR_DBF;
sp_helprotect SE_TRDS_DBF;

sp_helpuser 'MUREXDB';
sp_helpsort;
sp_configure 'quoted';
sp_who;
sp_lock @verbose=1;
sp_showplan 17,NULL,NULL,NULL;
sp_cacheconfig;
sp_rename TRN_CPDF_DBF,TRN_CPDF_DBF_ORI;
select * from master..sysdevices;
sp_audit 'delete', 'all', 'claire', 'on';
setuser 'MUREXDB';

set statistics time,io,plancost on;
set showplan on;
set statement_cache off;
dbcc traceon(3604);
dbcc traceon(3604,9528); -- format the output of plancost
dbcc cacheremove ('BBVA_PROD_REF','DPI_ID_DBF');
set option show_missing_stats on;

select * from master..sysprocesses where spid=91;
select db_name()+'@'+@@servername 'Server details',name,crdate,type from sysobjects where name like 'hp440srv#613%'; --H399634_H1S
select name,id from sysobjects where type='U' and name like 'TRN_HDR_%';
select * from syscolumns where id = 1929523372;
select * from sysusers where uid=2;
select db_name(), * from sysstatistics where id=(select object_id('ACC_EVTS_L_DBF'));
select object_id('TRN_HDR_DBF');
select * from systypes order by type;

select row_count(db_id(),object_id('[PS_FX_RISK')); -- number of rows in a table
select datachange('TRN_HDR_DBF',null,null); -- this query displays the % of data changes since the last update stats, good indicator to see if update statistics should be executed.
select object_name(734751160);

-- check crypted columns
select obj.name, col.name, col.type, typ.name, col.length, case col.status when 0 then 'NOT NULL' when 3 then 'NULL' end
from sysobjects obj join syscolumns col on obj.id = col.id join systypes typ on col.type = typ.type and col.usertype = typ.usertype
where col.encrdate is not null;
-- RDB scope SQL
select * from RDB_OBJECT_DBF where M_CLASS_NAME like '%ModifierSettingOutput%';
select * from RDB_OBJECT_DBF where M_OBJECT_ID='CM.9';
select * from RDB_CLASS_DBF 
where M_CLASS_NAME in (select M_CLASS_NAME from RDB_OBJECT_DBF where M_OBJECT_ID='CM.207');
select * from RDB_CLASS_DBF where M_TABLE_NAME='FCE_MODSTG_DBF';
select M_CLASS_NAME,M_TABLE_NAME from RDB_CLASS_DBF where M_TABLE_NAME like '%QUE_CFGTPL_%';
select * from RDBCNSTR_DBF where M_RFD_TABLE_NAME like '%FCE_MODSTG%'; and M_RFD_FORMULA='M_ID';
select 'select '+M_RFG_FORMULA+' from '+M_RFG_TABLE_NAME+' where '+M_RFG_FORMULA+' = 24383' 
from RDBCNSTR_DBF where M_RFD_TABLE_NAME='RPO_DMSETUP_COLUMN_DBF'; and M_RFD_FORMULA='M_ID';
select * from RDBCNSTR_KEY_DBF where M_TABLE_NAME like 'RS_MDRSR%';
-- undo migrate users
truncate table MX_USER_DBF;
truncate table MX_GROUP_DBF;
truncate table MX_USER_GROUP_DBF;
select * into TRN_GAG1_BDF_BKP from TRN_GAG1_DBF;
drop table TRN_GAG1_DBF;
select * into TRN_GAG1_DBF from TRN_USRD_DBF;
select * into TRN_GAG2_BDF_BKP from TRN_GAG2_DBF;
drop table TRN_GAG2_DBF;
select * into TRN_GAG2_DBF from USR_CFG_DBF;
---- Configuration Template list
select M_NAME from CFGT_TMPL_DBF;
---- client indexes
truncate table RDBCSNDX_DBF;
select * from RDBCSNDX_DBF; where M_TABNAME like 'MPX_VOL%';
select * from RDBCSNDX_DBF where M_EXPRESSION like 'create unique clustered index%' and M_TABNAME='MPX_VOL1';
---- RichClient related SQL
select MESSAGE_TIME_STAMP,str_replace(str_replace(PATH,'murex.installation.',''),'automaticTransfer','autoTrans'), 
STEP, GSTATUS,MX_BUILD_ID
from MXODR_ASSEMBLY_LOG 
where STEP like '%Adapt%'
order by MESSAGE_ID;
select * from MXODR_ASSEMBLY_LOG;
select * from NON_IDPT_DBF where STEP = 'InitializationAll';
------ workflows initialization all
select (select count(1) from STPFC_ENTRY_TABLE) as 'Contract entries', (select count(1) from STPEVT_ENTRY_TABLE) as 'Event entries',(select count(1) from STPSI_ENTRY_TABLE) as 'Settlement entries', (select count(1) from STPDLV_ENTRY_TABLE) as 'Deliverable entries';
truncate table STPFC_ENTRY_TABLE;
truncate table STPEVT_ENTRY_TABLE;
---- DPI_ID_DBF
select * from DPI_ID_DBF where M_LABEL1='SPB';
update DPI_ID_DBF set M_UNIQUE_ID=10155432 where M_LABEL1 = 'SPB' and M_LABEL2 = 'TRN_NB'; -- current value 10155432
---- TRN_HDR_DBF
select count(1) from TRN_HDR_DBF;
update TRN_HDR_DBF set M_TYPOLOGY=0;
select 'select top 10 M_NB from TRN_HDR_DBF where M_TRN_FMLY='''+rtrim(M_TRN_FMLY)+''' and M_TRN_GRP='''+rtrim(M_TRN_GRP)+''' and M_TRN_TYPE='''+rtrim(M_TRN_TYPE)+''''+char(10)+'go' from TRN_HDR_DBF group by M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE;
select top 10 M_NB from TRN_HDR_DBF where M_TRN_FMLY='IRD' and M_TRN_GRP='BOND' and M_TRN_TYPE='';
select top 10 M_NB from TRN_HDR_DBF where M_TRN_FMLY='CURR' and M_TRN_GRP='FXD' and M_TRN_TYPE='FXD';
select M_TYPOLOGY, count(1) from TRN_HDR_DBF group by M_TYPOLOGY;
select distinct(M_TYPOLOGY) from TRN_HDR_DBF;
select * from CONTRACT_DBF where M_REFERENCE=30007079;
---- VRS_INFO_DBF
select * from VRS_INFO_DBF;
----TRN_DSKD_DBF
select db_name(),M_LABEL,M_DESC,M_DATE from TRN_DSKD_DBF;
select * from TRN_GCFG_DBF;
---- Misc
select O.name, O.loginame, space_used_kb=(used_pages(db_id(),O.id)*4) --space_used_kb contains space used by data and index
from sysobjects O
where O.type = 'U'
order by space_used_kb desc;