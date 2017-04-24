select * from master..syslisteners;
select @@version;
select @@spid;
select @@dbts,convert(varchar(30),@@dbts),convert(bigint,@@dbts);
select hextoint(@@dbts);
select db_name()as db_used , user_name();count(1) as total_rows from TRN_HDR_DBF;

sp_help CTP_TYPES_DBF; --COREPL_REP DYN_AUDIT_REP
sp_spaceused MPY_DIV_NEW_DBF, 1;
sp_helpindex CTP_REVH_DBF;
sp_helprotect TRN_HDR_DBF;
sp_helpdb; GOLDEN_IMPORT_MR_MLC;
sp_helpuser;
sp_configure 'quoted';
sp_who;
sp_lock @verbose=1;
sp_showplan 17,NULL,NULL,NULL;

setuser 'MUREXDB';

set statistics time,io,plancost on;
set showplan on;
set statement_cache off;
dbcc traceon(3604);
dbcc traceon(3604,9528); -- format the output of plancost
dbcc cacheremove ('BBVA_PROD_REF','DPI_ID_DBF');
set option show_missing_stats on;

select * from sysprocesses where spid=148;
select * from sysobjects where name like '%COMB%'; --H399634_H1S
select * from syscolumns where id = 1309738675;
select * from sysusers where uid=2;
select db_name(), * from sysstatistics where id=(select object_id('ACC_EVTS_L_DBF'));
select db_name(), * from systabstats where id=(select object_id('ACC_EVTS_L_DBF'));
select object_id('TRN_HDR_DBF');

select datachange('TRN_HDR_DBF',null,null); -- this query displays the % of data changes since the last update stats, good indicator to see if update statistics should be executed.
update statistics TRN_HDR_DBF(M_PURPOSE);
create index MPY_RTC_DBF_SST0 on MPY_RTC_DBF(M_PDRVNG_PRM) with statistics using 500 values;
create table TYPO_MAP_DBF(ID int, TYPO_LABEL varchar(50));
alter table BE_STG_DBF drop M_E_DATE, M_S_DATE;


-- RDB scope SQL
select * from RDB_OBJECT_DBF where M_CLASS_NAME in ('mx.statics.organization.Party');
select * from RDB_OBJECT_DBF where M_OBJECT_ID='CM.124';
select * from RDB_CLASS_DBF where M_CLASS_NAME in (select M_CLASS_NAME from RDB_OBJECT_DBF where M_OBJECT_ID='CM.124');
select * from RDB_CLASS_DBF where M_TABLE_NAME like '%ACC_CLCTPL%';
select * from RDBCNSTR_DBF where M_RFG_TABLE_NAME='TRN_ENTD_DBF'; and M_RFD_TABLE_NAME='RT_LOAN_DBF';
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFD_TABLE_NAME,M_RFD_FORMULA from RDBCNSTR_DBF where M_RFG_TABLE_NAME='TRN_ENTD_DBF'; and M_RFG_FORMULA = 'M_NB_MODIF';
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFG_RELATIONSHIP,M_RFD_TABLE_NAME,M_RFD_FORMULA,M_RFD_RELATIONSHIP from RDBCNSTR_DBF where M_RFD_TABLE_NAME='CNT_JUR_DBF'; and M_RFG_FORMULA='M_NB_MODIF';
select 'select * from '+M_RFG_TABLE_NAME+' where '+M_RFG_FORMULA+' = 152940035;' from RDBCNSTR_DBF where M_RFD_TABLE_NAME='CR_BSKH_DBF'; and M_RFD_FORMULA='M_LABEL';
select * from RDBCNSTR_KEY_DBF where M_TABLE_NAME like 'RS_MDRSR%';

--3.1 queries
select * from TABLE#STRUCT#TAB_LNK_DBF;
select * from TABLE#STRUCT#TAB_UTH_DBF where M_LABEL='CUST_INFO' ;
select * from TABLE#STRUCT#TAB_UTF_DBF where M_HEADER=20008;
select * from TABLE#STRUCT#TAB_UTFS_DBF;  where M_HEADER=20008;
select top 10 * from TRN_HDR_DBF;
select this_.M_REFERENCE as M1_27_2_, this_.M_LABEL as M2_27_2_, this_.M_OSP_RIGHTS as M4_27_2_, osprightst2_.M_REFERENCE as M1_14_0_, osprightst2_.M_LABEL as M2_14_0_, osprightst2_.M_OSP_RIG_MATCHER_TEMPLATE as M3_14_0_, osprightst2_.M_OSP_RIG_VAL_TEMPLATE as M4_14_0_, osprightsv3_.M_REFERENCE as M1_20_1_, osprightsv3_.M_LABEL as M2_20_1_, osprightsv3_.M_LOCK_SUPERVISOR as M3_20_1_ from TRN_GRPD_DBF this_ left outer join OSP_RIGHTS_DBF osprightst2_ on this_.M_OSP_RIGHTS=osprightst2_.M_REFERENCE left outer join OSP_RIG_VAL_DBF osprightsv3_ on osprightst2_.M_OSP_RIG_VAL_TEMPLATE=osprightsv3_.M_REFERENCE where this_.M_LABEL='10';
--- test the possibility to change the contract number to 30000
select * from DPI_ID_DBF where M_LABEL1='HEDGE' and M_LABEL2='CONTRACT'; -- current value 10207310
--- FebDB migration query
select * into RT_NPLN_DBF_BCK from RT_NPLN_DBF;
select * into NPD_BDY_DBF_BCK from NPD_BDY_DBF;
delete from NPD_BDY_DBF where M_LEG_ID = 1644081;
delete from RT_NPLN_DBF where M_NB = 1644081;
delete from NPD_BDY_DBF where M_LEG_ID = 1604231;	
delete from RT_NPLN_DBF where M_NB = 1604231;
delete from NPD_BDY_DBF where M_LEG_ID = 1567801;
delete from RT_NPLN_DBF where M_NB = 1567801;
---
select M_NB, M_MRPL_ONB,M_MOP_LAST,M_OPT_MOPNB,M_OPT_MOPCNT,M_LEXTREF, M_LEVTEXTREF,M_LIMPEXTREF from TRN_HDR_DBF where M_NB=50603;
select * from TRN_EXT_DBF where M_TRADE_REF=50603;

select count(*) from TRN_HDR_DBF where M_TRN_FMLY='EQD'; --1224614 rows in 2.11 / 14307 rows in 3.1
from TRN_HDR_DBF t join TRN_EXT_DBF e1 on t.M_NB=e1.M_TRADE_REF and t.M_LEVTEXTREF=e1.M_REFERENCE join TABLE#DATA#DEALIRD_DBF u on e1.M_UDF_REF=u.M_NB
where t.M_TRN_FMLY='EQD';
select count(*) from TRN_CPDF_DBF;
select M_NB_TRADE from SST#TABLE#DATA#DEALIRD_DBF group by M_NB_TRADE having count(1)>1;
select t.M_NB, e1.M_REFERENCE, u.*
from TRN_HDR_DBF t join TRN_EXT_DBF e1 on t.M_NB=e1.M_TRADE_REF join TRN_EXT_DBF e2 on e1.M_TRADE_REF=e2.M_TRADE_REF join TABLE#DATA#DEALIRD_DBF u on e1.M_UDF_REF=u.M_NB
where t.M_NB=2302 and e1.M_REFERENCE>e2.M_REFERENCE;
select * from TRN_EXT_DBF where M_TRADE_REF=2302;
select count(1) from TABLE#DATA#DEALIRD_DBF union select count(1) from SST#TABLE#DATA#DEALIRD_DBF;
select h.M_NB as M_NB_TRADE,u.* into SST#TABLE#DATA#DEALIRD_DBF
from TRN_HDR_DBF h join TRN_EXT_DBF e on h.M_NB = e.M_TRADE_REF join TABLE#DATA#DEALIRD_DBF u on e.M_UDF_REF = u.M_NB
where h.M_TRN_FMLY='IRD';
select T1.TIMESTAMP, T1.M_IDENTITY, T1.M_LABEL, T1.M_DIMENSION, T1.M_DEF_FREQ, T1.M_DEF_UNIT, T1.M_OPENCLOSED, T1.M_BASED_ON, T1.M_REL_ABS, T1.M_LABELTWO, T1.M_MATSETTY, T1.M_MATSETCO, T1.M_FOR_BACK, T1.M_RECURSIF, T1.M_ADJTSTYN, T1.M_ADJTRUST, T1.M_ADJTRUCO, T1.M_ADJTCOYN, T1.M_GENERAT, T1.M_IDENTICAL, T1.M_CALENDAR, T1.M_STRCALEN, T1.M_ETOEFLAG, T1.M_INVDATADJF, T1.M_SCONV, T1.M_ECONV, T1.M_SSHIFT, T1.M_ESHIFT, T1.M_NEWMODE, T1.M_ESTUB, T1.M_ALGORITHM, T1.M_SLSH_NEW_SCHEDULES, T1.M_SLSH_OLD_BROKEN_PERIOD, T1.M_SLSH_OLD_REC_SCHEDS, T1.M_SLSH_RT_ROLL_FULL_COUPON from DAT_ECH_DBF T1  where (T1.M_LABEL = ' 1WEEK MODFOL   ' and T1.M_DIMENSION =  0. and T1.M_GENERAT =  0.);
select * from 
select b.M_LABEL, b.M_TYPE, b.M_SIZE
from TABLE#STRUCT#TAB_UTH_DBF h join TABLE#STRUCT#TAB_UTF_DBF b on h.M_REF=b.M_HEADER
where h.M_LABEL='CUST_INFO';
---- Ariane audit tables
select * from AUD_D_GENERAL_SETTINGS_DBF;
select * from AUD_I_GENERAL_SETTINGS_DBF;
select * from AUD_U_MDI_LNK_SET_STG_DBF;
select * from RS_BDSET_SUBH_DBF;
---- Configuration Template list
select M_NAME from CFGT_TMPL_DBF;
---- number of rows in a table
select row_count(db_id(),object_id('[PS_FX_RISK'));
---- client indexes
truncate table RDBCSNDX_DBF;
select * from RDBCSNDX_DBF; where M_TABNAME like 'MPX_VOL%';
select * from RDBCSNDX_DBF where M_EXPRESSION like 'create unique clustered index%' and M_TABNAME='MPX_VOL1';
---- RichClient related SQL
select * from NON_IDPT_DBF where STEP like '%ypolog%';
delete from NON_IDPT_DBF where STEP='InitializationAll';
------ workflows initialization all
select (select count(1) from STPFC_ENTRY_TABLE) as 'Contract entries', (select count(1) from STPEVT_ENTRY_TABLE) as 'Event entries',(select count(1) from STPSI_ENTRY_TABLE) as 'Settlement entries', (select count(1) from STPDLV_ENTRY_TABLE) as 'Deliverable entries';
truncate table STPFC_ENTRY_TABLE;
truncate table STPEVT_ENTRY_TABLE;
------ get audit of migration
select MESSAGE_TIME_STAMP,PATH, STEP, GSTATUS,MX_BUILD_ID from MXODR_ASSEMBLY_LOG order by MESSAGE_ID;
---- consolidation related 
select CLASSIFICATION_KEY_P, SUB_CLASSIFICATION_KEY, TRADE_NUMBER, M_TRN_STATUS from PS_POS_EX_E ps join TRN_HDR_DBF tr on ps.TRADE_NUMBER=tr.M_NB where CLASSIFICATION_KEY_P=20834;
select M_LABEL,count(*) from SST_CONSO_TMP2 where M_LABEL in ('Bond','Bond Future','Bond Option','Callable Bond','CDS','CDS Index','Depo','FRA','FX Future','Spot','FX Swap','IR Future','IR Future Option','IRS','Repo BD','SCF','Xccy Swap') group by M_LABEL;
select typ.M_LABEL,count(*) from 
TYPOLOGY_DBF typ join CLASS_ID_DBF clas on typ.M_REFERENCE=clas.M_TYPO 
join CLASSIFICATION_KEYS_P_DBF keys on clas.M_FIN_ID=keys.M_CLASSID
where typ.M_LABEL in ('Bond','Bond Future','Bond Option','Callable Bond','CDS','CDS Index','Depo','FRA','FX Future','Spot','FX Swap','IR Future','IR Future Option','IRS','Repo BD','SCF','Xccy Swap')
group by typ.M_LABEL;
------ Francois SQLs
select M_REF into MYSIMULATION_PTFREFS_TMP from TRN_PFLD_DBF where M_LABEL in('CORTO PLAZO');
select M_TRN_GTYPE, M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE,M_TYPOLOGY, count(*) from TRN_HDR_DBF where M_SRC_PFOLIO in (select M_REF from MYSIMULATION_PTFREFS_TMP) group by M_TRN_GTYPE, M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE,M_TYPOLOGY order by M_TRN_GTYPE, M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE,M_TYPOLOGY;
select M_TRN_GTYPE, M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE, count(*) from TRN_HDR_DBF where M_SRC_PFOLIO in (select M_REF from MYSIMULATION_PTFREFS_TMP) group by M_TRN_GTYPE, M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE order by M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE;
select PS_FXOPT_E.CLASSIFICATION_KEY_P, PS_FXOPT_E.SUB_CLASSIFICATION_KEY into MYSIMULATION_POS_TMP from PS_FXOPT_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP));
insert into  MYSIMULATION_POS_TMP select PS_POS_EX_E.CLASSIFICATION_KEY_P, PS_POS_EX_E.SUB_CLASSIFICATION_KEY from PS_POS_EX_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_RT_LNMOD_E.CLASSIFICATION_KEY_P, PS_RT_LNMOD_E.SUB_CLASSIFICATION_KEY from PS_RT_LNMOD_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_SBP_ADD_FLOW_E.CLASSIFICATION_KEY_P, PS_SBP_ADD_FLOW_E.SUB_CLASSIFICATION_KEY from PS_SBP_ADD_FLOW_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_SBP_TRADE_E.CLASSIFICATION_KEY_P, PS_SBP_TRADE_E.SUB_CLASSIFICATION_KEY from PS_SBP_TRADE_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_SE_COD_E.CLASSIFICATION_KEY_P, PS_SE_COD_E.SUB_CLASSIFICATION_KEY from PS_SE_COD_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_SE_CUD_E.CLASSIFICATION_KEY_P, PS_SE_CUD_E.SUB_CLASSIFICATION_KEY from PS_SE_CUD_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_TRN_CASH_E.CLASSIFICATION_KEY_P, PS_TRN_CASH_E.SUB_CLASSIFICATION_KEY from PS_TRN_CASH_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_TRN_XF_E.CLASSIFICATION_KEY_P, PS_TRN_XF_E.SUB_CLASSIFICATION_KEY from PS_TRN_XF_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
insert into  MYSIMULATION_POS_TMP select PS_FX_RISK_E.CLASSIFICATION_KEY_P, PS_FX_RISK_E.SUB_FINKEY_ID as SUB_CLASSIFICATION_KEY from PS_FX_RISK_E where (PORTFOLIO IN (select M_REF from MYSIMULATION_PTFREFS_TMP) );
select distinct CLASSIFICATION_KEY_P,SUB_CLASSIFICATION_KEY into MYSIMULATION_BUFFER_TMP from MYSIMULATION_POS_TMP;
select CLASSIFICATION_KEYS_P_DBF.M_TRN_GTYPE, MYSIMULATION_BUFFER_TMP.CLASSIFICATION_KEY_P, MYSIMULATION_BUFFER_TMP.SUB_CLASSIFICATION_KEY into MYSIMULATION_MUREXPOS_TMP from MYSIMULATION_BUFFER_TMP, CLASSIFICATION_KEYS_P_DBF where CLASSIFICATION_KEYS_P_DBF.M_CLASKEYID=MYSIMULATION_BUFFER_TMP.CLASSIFICATION_KEY_P;
select M_TRN_GTYPE, count(*) from MYSIMULATION_MUREXPOS_TMP group by M_TRN_GTYPE;
select pos.M_TRN_GTYPE,typo.TYPO_LABEL, count(*) from MYSIMULATION_MUREXPOS_TMP pos join TYPO_MAP_DBF typo on pos.M_TRN_GTYPE=typo.ID group by pos.M_TRN_GTYPE,typo.TYPO_LABEL;
---- DPI_ID_DBF
select * from DPI_ID_DBF where M_LABEL1='SPB';
update DPI_ID_DBF set M_UNIQUE_ID=10155432 where M_LABEL1 = 'SPB' and M_LABEL2 = 'TRN_NB'; -- current value 10155432
---- TRN_HDR_DBF
select M_NB, M_TRN_FMLY, M_TRN_GRP, M_TRN_TYPE from TRN_HDR_DBF where M_CONTRACT=209270;
select max(M_NB)from TRN_HDR_DBF; where M_TRN_TYPE='XSW';--10924420
select db_name(),count(1) from TRN_HDR_DBF;
select top 10 M_CONTRACT,M_NB from TRN_HDR_DBF where M_TRN_TYPE='SWLEG' and M_CONTRACT=209270;
select max(M_NB) from TRN_HDR_DBF where M_TRN_TYPE='SWLEG'; --10934067
---- VRS_INFO_DBF
select * from VRS_INFO_DBF;
----TRN_DSKD_DBF
select * from TRN_DSKD_DBF;
---- Datamart related queries
select top 10 * from ACT_JOB_DBF order by M_DATE DESC;
select * from DYN_AUDIT_REP where M_OUTPUTTBL='COREPL.REP' and M_TAG_DATA='BCM';
select top 10 * from COREPL_REP where M_REF_DATA in (select M_REF_DATA from DYN_AUDIT_REP where M_OUTPUTTBL='COREPL.REP' and M_TAG_DATA='BCM');
select * from COREPL_REP where M_NB = 4502825;
---- BBVA filter tables
select * from FLT_MAP_BANCOMER_DBF where M_NB= 4502825;
select count(1) from FLT_MAP_BBVA_DBF;
---- UDF infos
select count(*) from TABLE#DATA#DEALIRD_DBF;
select u.M_LABEL as 'Field name', case u.M_ETYPE when 1 then 'Manual' when 2 then 'List' end 'Field input type',u.M_ELABEL 'List table', l.M_STABLE as 'Systemtable', l.M_UTABLE as 'User defined structure name'
from TABLE#STRUCT#TAB_UTF_DBF u
join TABLE#STRUCT#TAB_UTH_DBF h on u.M_HEADER=h.M_REF
join TABLE#STRUCT#TAB_LNK_DBF l on h.M_LABEL=l.M_UTABLE
join TABLE#STRUCT#TAB_LNKI_DBF li on l.M_REF=li.M_REF
group by u.M_LABEL,l.M_STABLE, l.M_UTABLE order by l.M_STABLE, l.M_UTABLE, u.M_LABEL;
---- Misc

-- information about batch of feeders
select  T1.M_DATE 'exec data', T1.M_IDJOB 'job id', T1.M_PID 'mx pid', T3.M_REFERENCE 'scanner ref',
        T4.M_BAT_REF 'batch ref', 
        case T4.M_STATUS when 0 then 'waiting' when 1 then 'processing' end 'batch status',
        T1.M_BATCH 'batch', T1.M_OWNER 'usr', T1.M_GROUP 'group', 
        T2.M_STATUS 'sts', T3.M_NB_BATCHES'#batches', T3.M_NB_ITEMS '#items', T4.M_ITEMS
from ACT_JOB_DBF T1 join ACT_JOBDAP_DBF T2 on T1.M_IDJOB=T2.M_IDJOB
     join BBVA_CONVERSION_DEBUG_DM..SCANNER_REP T3 on T1.M_IDJOB=convert(int,T3.M_EXT_ID)
     join BBVA_CONVERSION_DEBUG_DM..BATCH_REP T4 on T3.M_REFERENCE=T4.M_SCANNER_ID
where T1.M_IDJOB=330;

select  dyn.M_IDJOB,dyn.M_DATEGEN,scn.M_REFERENCE, scn.M_NB_ITEMS,
        case when dyn.M_EXE_STATUS = 'T' then 'On-going' when dyn.M_EXE_STATUS = 'F' then 'Failed' end as STATUS, 
        count(*) as REMAINING, ((scn.M_NB_ITEMS - count(*))/scn.M_NB_ITEMS) * 100 as PCT_COMPLETE
from DYN_AUDIT_REP dyn join SCANNER_REP scn on convert(char,dyn.M_IDJOB) = scn.M_EXT_ID
        join BATCH_REP bat on scn.M_REFERENCE = bat.M_SCANNER_ID
        join ITEM_REP itm on itm.M_BAT_REF= bat.M_BAT_REF and itm.M_SCANNER_ID = bat.M_SCANNER_ID
group by dyn.M_IDJOB,scn.M_REFERENCE order by dyn.M_IDJOB;-- Remaining deals to be completed per batch of feeders

select dyn.M_IDJOB,dyn.M_DATEGEN,scn.M_REFERENCE, itm.M_ITM_REF
from DYN_AUDIT_REP dyn join SCANNER_REP scn on convert(char,dyn.M_IDJOB) = scn.M_EXT_ID
    join BATCH_REP bat on scn.M_REFERENCE = bat.M_SCANNER_ID
    join ITEM_REP itm on itm.M_BAT_REF= bat.M_BAT_REF and itm.M_SCANNER_ID = bat.M_SCANNER_ID
where dyn.M_IDJOB = 1306763; -- list of remaining deals to be completed per batch of feeders
select M_IDJOB, M_DATEGEN, M_DELETED, M_TAG_DATA from DYN_AUDIT_REP where M_DELETED='N' and M_TAG_DATA='BBVA'; -- get information about the audit of batch of feeders execution
-- e-tradepad information
select distinct(M_OWNER) from EBX_HDR_DBF order by M_OWNER;
select * from EBX_HDR_DBF where M_DOMAIN='e-Tradepad'and M_OWNER in ('REALTIME','MUREXFO');
select T1.M_LABEL, T1.M_DISPLAY from EBX_BOX_DBF T1, EBX_HDR_DBF T2 where T1.M_KEY=T2.M_BOXES and T2.M_OWNER='REALTIME';
select T1.M_LABEL, T1.M_DISPLAY from EBX_BOX_DBF T1 where T1.M_LABEL in ('Validation','Daily','Lookuptables','Usedmarketdata','Tradequery','Multi','OnTheFlyFXD','OnTheFly(Mid)','OnTheFly(B/A)','IRS','IRSButterfly','IRSTenorSpread','test','TEST','test2');
select * from NPD_HDR_DBF; where M_OWNER='MUREXFO' order by M_LABEL;
-- get info from STP right screen
select G.M_LABEL, PC.M_LABEL, WFT.M_TPL_LBL, STP_T.M_LABEL
from TRN_GRPD_DBF G
left join GRP_STP_DBF GRP_STP on G.M_REFERENCE = GRP_STP.M_GRP_REF
left join STP_RGH_TPL_GBL_DBF STP_T on GRP_STP.M_RIGHT_DATA = STP_T.M_REFERENCE
left join TRN_PC_DBF PC on GRP_STP.M_PC_REF = PC.M_REFERENCE
left join WFTPLRI_DBF WFT on GRP_STP.M_STP_RIGHTS = WFT.M_RIGHTS_LBL
order by G.M_LABEL;
-- get info from Portfolio rights
select G.M_GROUP, T.M_LABEL,P.M_LABEL,
case G.M_ACCESS when 0 then 'Read/Write' when 1 then 'Read only' when 2 then 'Deny' when 4 then 'Write only' end
from MUB#GRP_RGT1_DBF G
join MUB#MUB_TREE_DBF P on G.M_NODE_REF=P.M_REF
join MUB#MUB_TPL_DBF T on P.M_TRE_GROUP= T.M_TRE_GROUP and G.M_TEMPLATE=T.M_REFERENCE
order by G.M_GROUP;
-- get sql engine rights
select  R.M_GROUP 'Group', R.M_TEMPLATE 'Template', R.M_EDIT 'Allow editing mode', T.M_NAME 'Package name',
        case T.M_FLAGS when 0 then 'no rights' when 1 then 'r' when 2 then 'i' when 3 then 'r/i' when 4 then 'd'
        when 5 then 'r/d' when 6 then 'i/d' when 7 then 'r/i/d' when 8 then 'm' when 9 then 'r/m' when 10 then 'i/m'
        when 11 then 'r/i/m' when 12 then 'm/d' when 13 then 'r/m/d' when 14 then 'i/m/d' when 15 then 'r/i/m/d' end 'Rights'
from SQL_RGHT_DBF R join SQL_TMPL_DBF T on R.M_TEMPLATE=T.M_LABEL order by R.M_GROUP;
-- get CfgMgmt rights
select * from CFGT_TMPL_RIGHTS_DBF order by M_GROUP_NAME;
-- get mxml exchange rights
select GROUP_NAME,SERVICE,LABEL from XML_SERVICE_GROUPS where SERVICE in ('MXTEMPLATES', 'MXDICTIONARY', 'MXMLEXCHANGE', 'MXDECISIONRULES') order by GROUP_NAME,SERVICE,LABEL;
--misc
select db_name(),count(1) from PS_POS_EX_E;

--2.11 queries
select top 10 * from TRN_CPDF_DBF where M_ID=2334;