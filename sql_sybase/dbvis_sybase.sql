select @@version;
select @@spid;
select db_name()as db_used , count(1) as total_rows from TRN_HDR_DBF;

sp_help RT_INSGN_DBF ; --COREPL_REP DYN_AUDIT_REP
sp_spaceused SST_TRADE_SCOPE_PJ01, 1;
sp_helpindex TRN_HDR_DBF;
sp_helprotect TRN_HDR_DBF;
sp_helpdb;
sp_helpuser;
sp_configure 'max online engine';

setuser 'MUREXDB';

set statistics time,io,plancost on;
set showplan on;
set statement_cache off;
dbcc traceon(3604,9528); -- format the output of plancost
set option show_missing_stats on;

select * from sysobjects where name like '%TRN_HDR%'; --H399634_H1S
select * from syscolumns where id = 1309738675;
select * from syscolumns where name='M_TP_BROKER0';
select * from sysindexes where name like '%PJ01%';
select * from sysusers where uid=2;
select object_id('TRN_HDR_DBF');

drop index TRN_HDR_DBF.TRN_HDR_SST0;
select datachange('TRN_HDR_DBF',null,null); -- this query displays the % of data changes since the last update stats, good indicator to see if update statistics should be executed.
update statistics TRN_HDR_DBF(M_PURPOSE);

-- RDB scope SQL
select * from RDB_OBJECT_DBF where M_CLASS_NAME in ('mx.contract.stb.Container','mx.contract.stb.Registration');
select * from RDB_OBJECT_DBF where M_OBJECT_ID='CM.91';
select * from RDB_CLASS_DBF where M_CLASS_NAME=(select M_CLASS_NAME from RDB_OBJECT_DBF where M_OBJECT_ID='CM.91');
select * from RDB_CLASS_DBF where M_TABLE_NAME like '%TRN_MOPD%';
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFD_TABLE_NAME,M_RFD_FORMULA from RDBCNSTR_DBF where M_RFG_TABLE_NAME like 'NPD_PAT_DBF'; and M_RFD_FORMULA='M_INSGEN%';
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFG_RELATIONSHIP,M_RFD_TABLE_NAME,M_RFD_FORMULA,M_RFD_RELATIONSHIP from RDBCNSTR_DBF where M_RFD_TABLE_NAME='RT_INSGN_DBF'; and M_RFG_FORMULA='M_LABEL';
select 'select * from '+M_RFG_TABLE_NAME+' where '+M_RFG_FORMULA+' = 152940035;' from RDBCNSTR_DBF where M_RFD_TABLE_NAME='CR_BSKH_DBF'; and M_RFD_FORMULA='M_LABEL';
select * from RDBCNSTR_KEY_DBF where M_TABLE_NAME like 'RS_MDRSR%';

--3.1 queries
select top  325 * from FX_ARCGR_DBF T1  order by T1.M_DESC asc;
select * from FX_ARCGR_DBF T1  where (T1.M_DESC = 'MTM_FIXINGS');
select * from FX_ARCCL_DBF T1  where (T1.M_LINK=1855670676.);
select * from HG000017_H1S T1;
select * from BG000017_HBS T1  where ((T1.M_KEYID in (156758) and (T1.M_DATE>='20150607')) and (T1.M_DATE<='20160607')) order by T1.M_DATE asc;
--rof correction
select M_NB, M_TRN_STATUS from TRN_HDR_DBF where M_NB in (2154490,2154491,2168198,2168199,2224091,2224092,2326681,2326682,2343378,2343392,2343400,2343408,2345329,2345331,2357243,2357248,2418954,2469078,2486951,2509363,2509371,2540380,2557657,2557663,2592872,2592876,2592889,2592891,2612714,2612716,2612717,2612718,2641057,2667260,3507067,3507100,3580931,3580941,3603132,3603148,6418223,6418225,7945803,7945805,7945807,7945814,8092691,8092698,8092707,8092708) order by M_TRN_STATUS;
select M_NB,M_INSTRUMENT,M_TRN_STATUS,M_PURGE_REF, M_PURGE_DATE,* from TRN_HDR_DBF where M_NB in (2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708);
--update TRN_HDR_DBF set M_TRN_STATUS='LIVE' where M_NB in (2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708);
select top 100 * from TRN_HDR_DBF;
select M_NB, M_GEN_NUM, M_GEN_NAT, M_INSTR_TYPE from RT_LOAN_DBF where M_NB in (2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708);
select * from RT_INSGN_DBF where M_GEN_NUM in (select M_GEN_NUM from RT_LOAN_DBF where M_NB in (2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708));
select * from RT_INSGN_DBF where M_INSTR='EURIBOR 3M' and M_INSTR_TYPE=2;
--rof correction for deal 2123214
update RT_LOAN_DBF set M_GEN_NAT=2 where M_NB=2123214;
update TRN_HDR_DBF set M_PURGE_REF=0 where M_NB=2123214;
--rof correction for deal 1139031
update RT_LOAN_DBF set M_GEN_NAT=2 where M_NB=1139031;
update TRN_HDR_DBF set M_PURGE_REF=0 where M_NB=1139031;
--rof correction for deals 2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708
--all those deals points to a generator of type template (RT_LOAN_DBF.M_GEN_NAT=0) but the corresponding generator is not a template but a generator copy. It's also the same type 'index EURIBOR 3M' so change RT_LOAN_DBF.M_GEN_NAT=2;
update RT_LOAN_DBF set M_GEN_NAT=2 where M_NB in (2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708);
update TRN_HDR_DBF set M_PURGE_REF=0 where M_NB in (2154490,2154491,2326681,2326682,2345329,2345331,2357243,2357248,2418954,2486951,2667260,3603132,3603148,8092691,8092698,8092707,8092708);
--update TRN_HDR_DBF set M_PURGE_REF=0 where M_NB=2123213;
select str_replace(M_SNAME,char(9),'+') from SE_ISS_DBF where M_SNAME like 'SANLAM LTD%';
select M_SNAME,substring(M_SNAME,10,1),ascii(substring(M_SNAME,10,1)) from SE_ISS_DBF where M_SNAME like 'SANLAM LTD%';
----get audit of migration
select MESSAGE_TIME_STAMP,PATH, STEP, GSTATUS,MX_BUILD_ID from MXODR_ASSEMBLY_LOG where STEP like '%validation%'order by MESSAGE_ID;
----query Murex counters table
select top 100 * from DPI_ID_DBF where M_LABEL1 like '%SPB%' and M_LABEL2 like '%TRN%'; 
-- update DPI_ID_DBF set M_UNIQUE_ID=30000000 where M_LABEL1='SPB' and M_LABEL2='TRN_NB'
----query TRN_HDR_DBF
select db_name(),count(1) from TRN_HDR_DBF;
select db_name(),TIMESTAMP,M_NB,M_MRPL_ONB,M_TRN_STATUS from TRN_HDR_DBF where M_NB in(109782,10155429,10155430,945892);
select T1.M_NB,T1.M_CONTRACT from TRN_HDR_DBF T1 join FLT_MAP_BBVA_DBF T2 on T1.M_NB=T2.M_NB where T2.M_NB=1416;
--update TRN_HDR_DBF set M_TRN_STATUS='LIVE' where M_NB=4010690;
----query VRS_INFO_DBF
select * from VRS_INFO_DBF;
----query TRN_DSKD_DBF
select * from TRN_DSKD_DBF;
----datamart related queries
select top 10 * from ACT_JOB_DBF order by M_DATE DESC;
select * from DYN_AUDIT_REP where M_OUTPUTTBL='COREPL.REP' and M_TAG_DATA='BCM';
select top 10 * from COREPL_REP where M_REF_DATA in (select M_REF_DATA from DYN_AUDIT_REP where M_OUTPUTTBL='COREPL.REP' and M_TAG_DATA='BCM');
select * from COREPL_REP where M_NB = 4502825;
----BBVA filter tables
select * from FLT_MAP_BANCOMER_DBF where M_NB= 4502825;
select count(1) from FLT_MAP_BBVA_DBF;
----UDF infos
select u.M_LABEL as 'Field name', case u.M_ETYPE when 1 then 'Manual' when 2 then 'List' end 'Field input type',u.M_ELABEL 'List table', l.M_STABLE as 'Systemtable', l.M_UTABLE as 'User defined structure name'
from TABLE#STRUCT#TAB_UTF_DBF u
join TABLE#STRUCT#TAB_UTH_DBF h on u.M_HEADER=h.M_REF
join TABLE#STRUCT#TAB_LNK_DBF l on h.M_LABEL=l.M_UTABLE
join TABLE#STRUCT#TAB_LNKI_DBF li on l.M_REF=li.M_REF
group by u.M_LABEL,l.M_STABLE, l.M_UTABLE order by l.M_STABLE, l.M_UTABLE, u.M_LABEL;
----
select count(1) from RT_CT_DBF where M_CURRENCY = '';
select U.M_REFERENCE 'user ref',U.M_LABEL 'user name',U.M_FULL_NAME 'user full name', G.M_LABEL 'groupe name' 
from MX_USER_DBF U join MX_USER_GROUP_DBF UG on U.M_REFERENCE = UG.M_USER_ID  join MX_GROUP_DBF G on UG.M_GROUP_ID = G.M_REFERENCE
where U.M_LABEL like 'BBVA1%' order by U.M_LABEL, G.M_LABEL;

select M_TRN_FMLY,M_TRN_GRP, M_TRN_TYPE, count(1) from TRN_HDR_DBF T join FLT_MAP_DBF M on T.M_NB = M.M_NB group by M_TRN_FMLY,M_TRN_GRP, M_TRN_TYPE order by count(1) DESC; --what s the representation of the deals in FLT_MAP_DBF?

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

--2.11 queries
select T1.TIMESTAMP, T1.M_IDENTITY, T1.M_NAME, T1.M_TITLE, T1.M_VERSION, T1.M_LINENUMBER, T1.M_COLNUMBER, T1.M_REFDATE, T1.M_LASTDATE, T1.M_REFYEAR, T1.M_YEARNUM, T1.M_PRECISION, T1.M_PERTYPE, T1.M_DAYINDEX from HIS_HDR_DBF T1  where  (T1.M_NAME = 'HG000017.HIS   ') ;
select T1.TIMESTAMP, T1.M_IDENTITY, T1.M_HISNAME, T1.M_LINE, T1.M_COLUMN, T1.M_NAME, T1.M_LABEL, T1.M_DEFATTR, T1.M_DEFDECIMAL, T1.M_DEFWIDTH from HIS_LNCL_DBF T1  where  (T1.M_HISNAME = 'HG000017.HIS   ')  order by T1.M_LINE asc ,T1.M_COLUMN asc ;
select T1.TIMESTAMP, T1.M_IDENTITY, T1.M_DATE16 from HG000017_HIS T1  where (T1.M_KEYNOBUF=27.) order by T1.M_LINE asc ,T1.M_COLUMN asc ,T1.M_KEYNOBUF asc ;
select T1.TIMESTAMP, T1.M_IDENTITY, T1.M_LINE, T1.M_COLUMN, T1.M_KEYNOBUF, T1.M_DATE1, T1.M_DATE2, T1.M_DATE3, T1.M_DATE4, T1.M_DATE5, T1.M_DATE6, T1.M_DATE7, T1.M_DATE8, T1.M_DATE9, T1.M_DATE10, T1.M_DATE11, T1.M_DATE12, T1.M_DATE13, T1.M_DATE14, T1.M_DATE15, T1.M_DATE16, T1.M_DATE17, T1.M_DATE18, T1.M_DATE19, T1.M_DATE20, T1.M_DATE21, T1.M_DATE22, T1.M_DATE23, T1.M_DATE24, T1.M_DATE25, T1.M_DATE26, T1.M_DATE27, T1.M_DATE28, T1.M_DATE29, T1.M_DATE30, T1.M_DATE31, T1.M_DATE32, T1.M_DATE33, T1.M_DATE34, T1.M_DATE35, T1.M_DATE36, T1.M_DATE37, T1.M_DATE38, T1.M_DATE39, T1.M_DATE40, T1.M_DATE41, T1.M_DATE42, T1.M_DATE43, T1.M_DATE44, T1.M_DATE45, T1.M_DATE46, T1.M_DATE47, T1.M_DATE48, T1.M_DATE49, T1.M_DATE50, T1.M_DATE51, T1.M_DATE52, T1.M_DATE53, T1.M_DATE54, T1.M_DATE55, T1.M_DATE56, T1.M_DATE57, T1.M_DATE58, T1.M_DATE59, T1.M_DATE60, T1.M_DATE61, T1.M_DATE62, T1.M_DATE63, T1.M_DATE64, T1.M_DATE65, T1.M_DATE66, T1.M_DATE67, T1.M_DATE68, T1.M_DATE69, T1.M_DATE70, T1.M_DATE71, T1.M_DATE72, T1.M_DATE73, T1.M_DATE74, T1.M_DATE75, T1.M_DATE76, T1.M_DATE77, T1.M_DATE78, T1.M_DATE79, T1.M_DATE80, T1.M_DATE81, T1.M_DATE82, T1.M_DATE83, T1.M_DATE84, T1.M_DATE85, T1.M_DATE86, T1.M_DATE87, T1.M_DATE88, T1.M_DATE89, T1.M_DATE90, T1.M_DATE91, T1.M_DATE92, T1.M_DATE93, T1.M_DATE94, T1.M_DATE95, T1.M_DATE96, T1.M_DATE97, T1.M_DATE98, T1.M_DATE99, T1.M_DATE100 from HG000017_HIS T1  where ((((T1.M_LINE=9.) and (T1.M_COLUMN=0.)) and (T1.M_KEYNOBUF>=23.)) and (T1.M_KEYNOBUF<=27.)) order by T1.M_KEYNOBUF asc ;
select * from TRN_BROKER_DBF where M_NB in (5631958,5634396,6401195,6401201,6401747,6401761,6467254,6801841,7110174,7110773,7112852);
select * from TRN_HDR_DBF where M_NB=5631958;
select top 10 * from TRN_CPDF_DBF where M_ID=2334;
select T1.TIMESTAMP, T1.M_IDENTITY, T1.M_NB, T1.M_LTI_NB, T1.M_GID, T1.M_NB_TISTAMP, T1.M_TRN_FMLY, T1.M_TRN_GRP, T1.M_TRN_TYPE, T1.M_TRN_GTYPE, T1.M_TRN_TYPO, T1.M_INSTRUMENT, T1.M_RSKSECTION, T1.M_PL_INSCUR, T1.M_PL_KEY1, T1.M_MKT_LABEL, T1.M_MKT_INDEX, T1.M_CNS_ACTIVE, T1.M_AGREED_TRN, T1.M_REAL, T1.M_COMMENT_BS, T1.M_CLIENT, T1.M_BINTERNAL, T1.M_BTRADER, T1.M_BPFOLIO, T1.M_BCOMMENT0, T1.M_BCOMMENT1, T1.M_BCOMMENT2, T1.M_BSTRATEGY, T1.M_BSECTION, T1.M_BENTITY, T1.M_BTRDSECT, T1.M_SINTERNAL, T1.M_STRADER, T1.M_SPFOLIO, T1.M_SCOMMENT0, T1.M_SCOMMENT1, T1.M_SCOMMENT2, T1.M_SSTRATEGY, T1.M_SSECTION, T1.M_SENTITY, T1.M_STRDSECT, T1.M_TRN_STATUS, T1.M_TRN_DATE, T1.M_TRN_TIME, T1.M_TRN_EXP, T1.M_SYS_DATE, T1.M_QTY_NB, T1.M_CREATOR, T1.M_CRE_CMMOUT, T1.M_NB_EXT, T1.M_BO_SGN, T1.M_BO_CMT, T1.M_BO_CNF, T1.M_ACC_PROR, T1.M_RPL_AMO, T1.M_RPL_AMTTYP, T1.M_RPL_AMT, T1.M_RPL_CUR, T1.M_RPL_USRDAT, T1.M_RPL_DATE1, T1.M_RPL_DATE2, T1.M_UPL_FLAG, T1.M_UPL_MODE, T1.M_UPL_AMTEVC, T1.M_UPL_AMT, T1.M_UPL_AMTDIS, T1.M_IRV_TYPE, T1.M_IRV_AMT, T1.M_FCP_REVAL, T1.M_HEDGE_FLAG, T1.M_HEDGED_ID, T1.M_HEDGED_MAT, T1.M_PAY_NET, T1.M_VAL_STATUS, T1.M_OLK, T1.M_MAIN, T1.M_FLW_SDATEF, T1.M_FLOW_FLAG, T1.M_AREA_CODE, T1.M_MRPL_FLAG, T1.M_MRPL_DATE, T1.M_MRPL_ONB, T1.M_NB_AMD, T1.M_DTE_AMD, T1.M_MOP_LAST, T1.M_MOP_CREAT, T1.M_MOP_CRSUB, T1.M_CNS_LOADFO, T1.M_BRK_THIRDP, T1.M_OPT_FLWFST, T1.M_OPT_FLWLST, T1.M_OPT_ACCLST, T1.M_OPT_MOPFST, T1.M_OPT_MOPLST, T1.M_OPT_MOPLSD, T1.M_OPT_MOPCNT, T1.M_OPT_MOP2, T1.M_OPT_MOPCOD, T1.M_OPT_MOPZON, T1.M_OPT_MOPZOA, T1.M_OPT_MOPSUB, T1.M_OPT_MOPOBS, T1.M_OPT_MOPDBS, T1.M_OPT_MOPNB, T1.M_BRW_NOM1, T1.M_BRW_NOMU1, T1.M_BRW_NOM2, T1.M_BRW_NOMU2, T1.M_BRW_RTE1, T1.M_BRW_RTE2, T1.M_BRW_MRG1, T1.M_BRW_MRG2, T1.M_BRW_STRK, T1.M_BRW_CP, T1.M_BRW_AE, T1.M_BRW_PR1, T1.M_BRW_PR2, T1.M_BRW_FV1, T1.M_BRW_FV2, T1.M_BRW_SDTE, T1.M_BRW_ODPL, T1.M_BRW_ODNC0, T1.M_BRW_ODNC1, T1.M_BRW_ODFC0, T1.M_BRW_ODFC1, T1.M_OPT_CMMNAT, T1.M_OPT_CMMDTE, T1.M_OPT_CMMCUR, T1.M_OPT_CMMSTL, T1.M_OPT_CMMSPD, T1.M_OPT_CMMSPS, T1.M_PURGE_STS, T1.M_PURGE_DATE, T1.M_PURGE_GRP, T1.M_SALES, T1.M_STS_FLAG, T1.M_LAT, T1.M_OPT_MOPVAL, T1.M_STAT_CAT, T1.M_SC_CUSTOM, T1.M_HOST_SYS, T1.M_CONTRACT, T1.M_SRC_PFOLIO, T1.M_DST_PFOLIO, T1.M_COUNTRPART, T1.M_SI_TCI, T1.M_COLLAGCAT from TRN_HDR_DBF T1  where  (T1.M_NB in (10150803,9146477))  and (((T1.M_REAL='2') or (T1.M_REAL='3')) and (((T1.M_BINTERNAL='Y') and (M_BPFOLIO in (select M_PTF_LABEL from GRP_SPTF_DBF where M_GRP_REF=1111 and M_PTF_RGT in (0, 1)))) or ((T1.M_SINTERNAL='Y') and (M_SPFOLIO in (select M_PTF_LABEL from GRP_SPTF_DBF where M_GRP_REF=1111 and M_PTF_RGT in (0, 1))))));
select top 10 M_NB, M_BCOMMENT1 from TRN_HDR_DBF where M_BCOMMENT1 <> '';
select distinct(M_BCOMMENT1) from TRN_HDR_DBF where M_BCOMMENT1 <> '';
select M_NB from TRN_HDR_DBF where M_BCOMMENT1='BSIUS_RES';