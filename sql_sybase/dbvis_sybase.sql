select * from master..syslisteners;
select @@servername;
select @@version;
select @@spid;
select db_name()as db_used , user_name();count(1) as total_rows from TRN_HDR_DBF;

sp_help TRN_CPDF_NEW; --COREPL_REP DYN_AUDIT_REP
sp_spaceused NPD_HDR_DBF, 1;
sp_helpindex TRN_CPDF_DBF;
sp_helprotect SE_TRDS_DBF;
sp_helpdb tempdb; MIG_MX;

sp_helpuser;
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

select * from sysprocesses where spid=148;
select db_name()+'@'+@@servername 'Server details',name,crdate,type from sysobjects where name like 'hp440srv#613%'; --H399634_H1S
select name,id from sysobjects where type='U' and name like 'TRN[_]CPDF[_]%';
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
select * from RDB_OBJECT_DBF where M_CLASS_NAME in ('mx.statics.query.config.QueryTemplate');
select * from RDB_OBJECT_DBF where M_OBJECT_ID='CM.243';
select * from RDB_CLASS_DBF 
where M_CLASS_NAME in (select M_CLASS_NAME from RDB_OBJECT_DBF where M_OBJECT_ID='CM.38');
select M_CLASS_NAME,M_TABLE_NAME from RDB_CLASS_DBF where M_TABLE_NAME like '%QUE_CFGTPL_%';
select * from RDBCNSTR_DBF where M_RFG_TABLE_NAME like '%SE_ROOT_DBF%'; and M_RFD_FORMULA='M_ID';
select 'select '+M_RFG_FORMULA+' from '+M_RFG_TABLE_NAME+' where '+M_RFG_FORMULA+' = 152940035' 
from RDBCNSTR_DBF where M_RFD_TABLE_NAME='CR_BSKH_DBF'; and M_RFD_FORMULA='M_ID';
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
select distinct(M_TYPOLOGY) from TRN_HDR_DBF;
select * from CONTRACT_DBF where M_REFERENCE=30007079;
---- VRS_INFO_DBF
select * from VRS_INFO_DBF;
----TRN_DSKD_DBF
select db_name(),M_LABEL,M_DESC,M_DATE from TRN_DSKD_DBF;
select * from TRN_GCFG_DBF;
---- Misc
--Import make sure Bsb not migrated
select * from RT_FLAGS_DBF where M_LABEL like '%MIGRATED_BSB%';
select top 10 * from USERNDX_DBF where M_DBFNAME like '%INDEX%';
delete from USERNDX_DBF where M_DBFNAME='INDEX' and M_NDXNAME='INDEX.ND0';
-- error while importing AmendmentAgent for couple
-- M_FLOW_ID=6 and M_WF_TPL=2
-- M_FLOW_ID=5 and M_WF_TPL=2
-- M_FLOW_ID=8 and M_WF_TPL=2
-- M_FLOW_ID=1 and M_WF_TPL=2
-- M_FLOW_ID=14 and M_WF_TPL=2
select * into WF_CFG_DBF_BKP from WF_CFG_DBF;
select * from WF_CFG_DBF union all select * from WF_CFG_DBF_BKP;
update WF_CFG_DBF set M_FLOW_ID = M_FLOW_ID+200 where M_FLOW_ID in (1,5,6,8,14) and M_WF_TPL=2;
select distinct M_FLOW_ID from WF_CFG_DBF;
select * from MD_ACTIVITY_FEEDER_DBF;
delete MD_ACTIVITY_FEEDER_DBF where M_IDENTITY = 1;

select 'print "update index statistics ' + name + ' in progress" ' + char(10) + 'update index statistics '+name from sysobjects where name like 'PS%' and type = 'U';

select * from (
select h.M_LABEL + ' : ' as 'Label',
case M_CATEGORY
    when 2000 then 'FX : Context : ' + a0.M_LABEL + ' : Router : ' + a0r.M_LABEL
    when 2001 then 'MarketData : RealtimeSubscriptionRuleTemplate : ' + a1.M_LABEL + ' : Router : ' + a1r.M_LABEL
    when 2002 then 'Pricing : Pricing template & favorites : ' + a2.M_LABEL + ' : Router : ' + a2r.M_LABEL
    when 2003 then 'MarketData : Permissioning rule : ' + a3.M_LABEL + ' : Router : ' + a3r.M_LABEL
    when 2004 then 'Pricing : Fast Deal Input : ' + a4.M_LABEL + ' : Router : ' + a4r.M_LABEL
    when 2005 then 'Processing : Display : ' + a5.M_LABEL + ' : Router : ' + a5r.M_LABEL
    when 2006 then 'Processing : MTM audit : ' + a6.M_LABEL + ' : Router : ' + a6r.M_LABEL
    when 2007 then 'Processing : Fixing : ' + a7.M_LABEL + ' : Router : ' + a7r.M_LABEL
    when 2008 then 'Processing : Netting : ' + a8.M_LABEL + ' : Router : ' + a8r.M_LABEL
    when 2010 then 'MarketData : Realtime setting : ' + a9.M_LABEL + ' : Router : ' + a9r.M_LABEL
    when 2011 then 'Risk engine : simulation screen assignment : ' + a10.M_LABEL
    when 2014 then 'MarketData : Swaption volatility assignment : ' + a11.M_LABEL + ' : Router : ' + a11r.M_LABEL
    when 2015 then 'MarketData : Cap floor volatility assignment : ' + a12.M_LABEL + ' : Router : ' + a12r.M_LABEL
    when 2017 then 'Model : FX volatility model assignment : ' + a13.M_LABEL + ' : Router : ' + a13r.M_LABEL
    when 2018 then 'MarketData : Inflation cap volatility assignment : ' + a14.M_LABEL + ' : Router : ' + a14r.M_LABEL
    when 2030 then 'General settings : Fx : ' + a15.M_LABEL + ' : Router : ' + a15r.M_LABEL
    when 2032 then 'General settings : Rates : ' + a16.M_DSP_LABEL + ' : Router : ' + a16r.M_LABEL
    when 2033 then 'General settings : Bonds : ' + a17.M_LABEL + ' : Router : ' + a17r.M_LABEL
    when 2034 then 'General settings : Equity : ' + a18.M_DSP_LABEL + ' : Router : ' + a18r.M_LABEL
    when 2035 then 'General settings : Credit : ' + a19.M_DSP_LABEL + ' : Router : ' + a19r.M_LABEL
    when 2036 then 'General settings : Commodities : ' + a20.M_DSP_LABEL + ' : Router : ' + a20r.M_LABEL
    when 2037 then 'General settings : MM : ' + a21.M_DSP_LABEL + ' : Router : ' + a21r.M_LABEL
    when 2038 then 'General settings : SecFin : ' + a22.M_DSP_LABEL + ' : Router : ' + a22r.M_LABEL
    when 2039 then 'General settings : Future : ' + a23.M_DSP_LABEL + ' : Router : ' + a23r.M_LABEL
end 'Settings'
from TRN_STG_DBF h join TRN_STGB_DBF b on h.M_REFERENCE = b.M_REFERENCE
     left join TRN_FXCTX_DBF a0 on b.M_SETTING = a0.M_REFERENCE -- FX context template
     left join RS_FXCTXH_DBF a0r on b.M_ROUTER = a0r.M_LABEL -- FX context router 
     left join MD_RTSRH_DBF a1 on b.M_SETTING = a1.M_REFERENCE -- MD realtime subscription template
     left join RS_MDRSRH_DBF a1r on b.M_ROUTER = a1r.M_LABEL -- MD realtime subscription router
     left join DCF_FAVH_DBF a2 on b.M_SETTING = a2.M_REFERENCE -- pricing template & favorites template
     left join RS_PRTMPH_DBF a2r on b.M_ROUTER = a2r.M_LABEL -- pricing template & favorites router
     left join MD_PR_DBF a3 on b.M_SETTING = a3.M_REFERENCE -- MD permission rule template
     left join RS_MDPRH_DBF a3r on b.M_ROUTER = a3r.M_LABEL -- MD permission rule router
     left join PRS_OPT_DBF a4 on b.M_SETTING = a4.M_REFERENCE -- pricing FDI template
     left join RS_PRFDIH_DBF a4r on b.M_ROUTER = a4r.M_LABEL -- pricing FDI router
     left join TRN_PDSET_DBF a5 on b.M_SETTING = a5.M_REFERENCE -- processing display template
     left join RS_PDSETH_DBF a5r on b.M_ROUTER = a5r.M_LABEL -- processing display router
     left join MTMA_RTGH_DBF a6 on b.M_SETTING = a6.M__INDEX_ -- processing mtm audit template
     left join RS_MASETH_DBF a6r on b.M_ROUTER = a6r.M_LABEL -- processing mtm audit router
     left join TRN_PFSET_DBF a7 on b.M_SETTING = a7.M_REFERENCE -- processing fixing template
     left join RS_PFSETH_DBF a7r on b.M_ROUTER = a7r.M_LABEL -- processing fixing router
     left join TRN_PNSET_DBF a8 on b.M_SETTING = a8.M_REFERENCE -- processing netting template
     left join RS_PNSETH_DBF a8r on b.M_ROUTER = a8r.M_LABEL -- processing netting router
     left join MD_RTST_DBF a9 on b.M_SETTING = a9.M_REFERENCE -- MD realtime settings template
     left join RS_MDRTSTH_DBF a9r on b.M_ROUTER = a9r.M_LABEL -- MD realtime settings router
     left join RTGVWRH_DBF a10 on b.M_SETTING = a10.M__INDEX_ -- riskEngine sim template
     left join RS_RISKH_DBF a10r on b.M_ROUTER = a10r.M_LABEL -- riskEngine sim router
     left join SW_VOLH_DBF a11 on b.M_SETTING = a11.M__INDEX_ -- MD swaption volatility template
     left join RS_SWVOLH_DBF a11r on b.M_ROUTER = a11r.M_LABEL -- MD swaption volatility router
     left join CF_VOLH_DBF a12 on b.M_SETTING = a12.M__INDEX_ -- MD capFloor volatility template
     left join RS_CFVOLH_DBF a12r on b.M_ROUTER = a12r.M_LABEL -- MD capFloor volatility router
     left join VOLX_SETTINGSH_DBF a13 on b.M_SETTING = a13.M__INDEX_ -- Model volfx assignment template
     left join RS_VOLMDLH_DBF a13r on b.M_ROUTER = a13r.M_LABEL -- Model volfx assignment router
     left join IC_VOLH_DBF a14 on b.M_SETTING = a14.M__INDEX_ -- MD inflation cap assignment template
     left join RS_ICVOLH_DBF a14r on b.M_ROUTER = a14r.M_LABEL -- MD inflation cap assignment router
     left join CU_CFG_T_DBF a15 on b.M_SETTING = a15.M_REFERENCE -- Gen settings FX template
     left join RS_FX_GEN_SETH_DBF a15r on b.M_ROUTER = a15r.M_LABEL -- Gen settings FX router
     left join RT_GSET_DBF a16 on b.M_SETTING = a16.M_REFERENCE -- Gen settings rates template
     left join RS_RTSETH_DBF a16r on b.M_ROUTER = a16r.M_LABEL -- Gen settings rates router
     left join RS_BDSET_SUBH_DBF a17 on b.M_SETTING = a17.M__INDEX_ -- Gen settings bonds template
     left join RS_BDSETH_DBF a17r on b.M_ROUTER = a17r.M_LABEL -- Gen settings bonds router
     left join EQ_GSET_DBF a18 on b.M_SETTING = a18.M_REFERENCE -- Gen settings equity template
     left join RS_EQSETH_DBF a18r on b.M_ROUTER = a18r.M_LABEL -- Gen settings equity router
     left join CRD_GSET_DBF a19 on b.M_SETTING = a18.M_REFERENCE -- Gen settings credit template
     left join RS_CRDSETH_DBF a19r on b.M_ROUTER = a19r.M_LABEL -- Gen settings credit router
     left join COM_GSET_DBF a20 on b.M_SETTING = a20.M_REFERENCE -- Gen settings commo template
     left join RS_COMSETH_DBF a20r on b.M_ROUTER = a20r.M_LABEL -- Gen settings commo router
     left join MM_GSET_DBF a21 on b.M_SETTING = a21.M_REFERENCE -- Gen settings MM template
     left join RS_MMSETH_DBF a21r on b.M_ROUTER = a21r.M_LABEL -- Gen settings MM router
     left join SECF_GSET_DBF a22 on b.M_SETTING = a22.M_REFERENCE -- Gen settings secFin template
     left join RS_SECFINSETH_DBF a22r on b.M_ROUTER = a22r.M_LABEL -- Gen settings secFin router
     left join FUT_GSET_DBF a23 on b.M_SETTING = a23.M_REFERENCE -- Gen settings future template
     left join RS_FUTSETH_DBF a23r on b.M_ROUTER = a23r.M_LABEL -- Gen settings future router
where h.M_LABEL='MAIN' -- this parameter is to be changed with the settings label you want to check
union all
select h.M_LABEL + ' : ' as 'Label',
case M_CATEGORY
    when 2041 then 'General settings : Shared : ' + a24.M_DSP_LABEL + ' : Router : ' + a24r.M_LABEL
    when 2043 then 'General settings : Volatility links : ' + a25.M_DSP_LABEL + ' : Router : ' + a25r.M_LABEL
    when 2044 then 'General settings : Investment management : ' + a26.M_DSP_LABEL + ' : Router : ' + a26r.M_LABEL
    when 2045 then 'MarketData : FX Volatility Source assignment : ' + a27.M_LABEL + ' : Router : ' + a27r.M_LABEL
    when 2054 then 'MarketData : Securities Volatility Source assignment : ' +  + ' : Router : ' + a28r.M_LABEL
    when 2055 then 'Model : IRD model assignment : ' +  + ' : Router : ' + a29r.M_LABEL
    when 2056 then 'Model : CRD model assignment : ' +  + ' : Router : ' + a30r.M_LABEL
    when 2057 then 'Model : COM model assignment : ' +  + ' : Router : ' + a31r.M_LABEL
    when 2058 then 'Model : FXD model assignment : ' +  + ' : Router : ' + a32r.M_LABEL
    when 2063 then 'Model : Cap floor vol model assignment : ' +  + ' : Router : ' + a33r.M_LABEL
    when 2064 then 'Model : Swaption model assignment : ' +  + ' : Router : ' + a34r.M_LABEL
    when 2065 then 'Model : CRD vol model assignment : ' +  + ' : Router : ' + a35r.M_LABEL
    when 2066 then 'Model : Infl Cap model assignment : ' +  + ' : Router : ' + a36r.M_LABEL
end 'Settings'
from TRN_STG_DBF h join TRN_STGB_DBF b on h.M_REFERENCE = b.M_REFERENCE
     left join SHR_GSET_DBF a24 on b.M_SETTING = a24.M_REFERENCE -- Gen settings shared template
     left join RS_SHRSETH_DBF a24r on b.M_ROUTER = a24r.M_LABEL -- Gen settings shared router
     left join VOL_GSET_DBF a25 on b.M_SETTING = a25.M_REFERENCE -- Gen settings volatility links template
     left join RS_VOLSETH_DBF a25r on b.M_ROUTER = a25r.M_LABEL -- Gen settings volatility links router
     left join AM_GSET_DBF a26 on b.M_SETTING = a26.M_REFERENCE -- Gen settings asset management template
     left join RS_AMSETH_DBF a26r on b.M_ROUTER = a26r.M_LABEL -- Gen settings asset management router
     left join FXVOLSRCH_DBF a27 on b.M_SETTING = a27.M__INDEX_ -- MD FX volatility source template
     left join RS_VOLSRCH_DBF a27r on b.M_ROUTER = a27r.M_LABEL -- MD FX volatility source router
     left join RS_SEVOL_MDLH_DBF a28r on b.M_ROUTER = a28r.M_LABEL -- MD securities volatility source router
     left join RS_IRD_MDLH_DBF a29r on b.M_ROUTER = a29r.M_LABEL -- Model IRD assignment router
     left join RS_CRD_MDLH_DBF a30r on b.M_ROUTER = a30r.M_LABEL -- Model CRD assignment router
     left join RS_COM_MDLH_DBF a31r on b.M_ROUTER = a31r.M_LABEL -- Model COM assignment router
     left join RS_FXD_MDLH_DBF a32r on b.M_ROUTER = a32r.M_LABEL -- Model FXD assignment router 
     left join RS_CFVOL_MDLH_DBF a33r on b.M_ROUTER = a33r.M_LABEL -- Model Cap Floor vol assignment router 
     left join RS_SWVOL_MDLH_DBF a34r on b.M_ROUTER = a34r.M_LABEL -- Model swaption assignment router
     left join RS_CRDVOL_MDLH_DBF a35r on b.M_ROUTER = a35r.M_LABEL -- Model CRD vol assignment router
     left join RS_INFLVOL_MDLH_DBF a36r on b.M_ROUTER = a36r.M_LABEL -- Model Infl Cap assignment router
where h.M_LABEL='MAIN' -- this parameter is to be changed with the settings label you want to check
) T1
where T1.Settings <> ''
order by T1.Settings;

select top 10 * from TRN_CPDF_DBF where M_LABEL = '000000001';

select * from MUREXDB.DPI_ID_DBF where M_LABEL1='SPB_TAB' and M_LABEL2='TAB_MEN.DBF';
select * from TABLE#LIST#DF_TYPEV_DBF;


select T1.M_LABEL, T1.M_CTP_CWT from TRN_GRPD_DBF T1
where T1.M_LABEL in ('ACCESS', 'BO', 'CONFIG', 'FO', 'FO_BC', 'FO_FINP', 'FO_FLEX', 'FO_LDN', 'FO_LT',
'FO_MAD', 'FO_ST', 'FO_TEST', 'FO_VOL', 'HOUSEKEEP', 'MO', 'MO2', 'MO_BC', 'RISK', 'RISK_BC', 'STATICDATA',
'SUPPORT', 'TEC', 'TEC_BC');

select * from STP_RGH_TPL_GBL_DBF;
select * from STP_RGH_TPL_SM_DBF;
select * from STP_RGH_TPL_BO_DBF;
select * from STP_RGH_TPL_PFL_DBF;
select * from STP_RGH_TPL_SM_DBF;
select * from STP_RGH_TPL_SMR_DBF;
select distinct(M_TREE) from STP_RGH_NODE_DBF;
select * from TYPOLOGY_DBF;

select N.M_TYPO_REF
from STP_RGH_NODE_DBF N left join TYPOLOGY_DBF T on N.M_TYPO_REF = T.M_REFERENCE
where T.M_REFERENCE is null and N.M_TYPE=2;

select * from STP_RGH_NODE_DBF where M_TYPO_REF = -1;

select T1.M_LABEL, T3.M_LABEL
from STP_RGH_NODE_DBF T1 join STP_RGH_NODE_DBF T2 on T1.M_REFERENCE = T2.M_PARENT
                         join TYPOLOGY_DBF T3 on T2.M_TYPO_REF = T3.M_REFERENCE
order by T1.M_LABEL, T3.M_LABEL;

select case H.M_TYPE
       when 1 then 'Contract/Package' when 2 then 'Deliverable' when 3 then 'Contract/Package event'
       when 4 then 'Deliverable event' when 5 then 'Settlement instruction' when 6 then 'Order'
       when 7 then 'Order event' when 8 then 'Account' when 9 then 'Account event'
       when 10 then 'Security' when 11 then 'Security event' when 12 then 'Hedge'
       when 13 then 'Hedge event' when 14 then 'Accounting entry' when 15 then 'Accounting entry event'
       when 16 then 'Inventory accounting entry' when 18 then 'Credit basket' when 19 then 'Margin requirement'
       when 20 then 'Transfer'
       end, 
       H.M_LABEL 'grouping template label', N1.M_REFERENCE 'folder_id', N1.M_LABEL 'folder', T.M_LABEL 'typo'
from STP_RGH_TREE_DBF H join STP_RGH_NODE_DBF N1 on H.M_REFERENCE = N1.M_TREE
                        join STP_RGH_NODE_DBF N2 on N1.M_REFERENCE = N2.M_PARENT
                        join TYPOLOGY_DBF T on N2.M_TYPO_REF = T.M_REFERENCE
order by H.M_TYPE, H.M_LABEL, N1.M_LABEL, T.M_LABEL;

--
select * from TRN_DSKD_DBF;
--select public strategy owned by a user not in the table user
select * into NPD_HDR_DBF_BKP from NPD_HDR_DBF;
select * from NPD_HDR_DBF where M_USER='TOTO';

update NPD_HDR_DBF set M_USER=M_OWNER where M_LABEL='Duada' and M_OWNER='REALTIME';

update NPD_HDR_DBF set M_USER='' where M_LABEL='Duada' and M_USER='TOTO';

select distinct(np.M_USER) from
NPD_HDR_DBF np left join MX_USER_DBF mx on np.M_USER = mx.M_LABEL
where np.M_USER <> '' and mx.M_LABEL is null;
-- update owner in NPD_HDR_DBF to an existing user
update NPD_HDR_DBF
set M_OWNER = 'REALTIME'
where M_OWNER not in (select M_LABEL from MX_USER_DBF);
-- update user in NPD_HDR_DBF to an existing user
update NPD_HDR_DBF
set M_USER = 'REALTIME'
where M_USER not in (select M_LABEL from MX_USER_DBF) and M_USER <> ''; -- statement is failing because of duplicate key
-- test the fix provided before the import sequence
select * into NPD_HDR_DBF_BKP from NPD_HDR_DBF;
update NPD_HDR_DBF
set M_USER = ''
where M_USER = 'TOTO' and M_PRC_MODE = 1;
-- PROBLEM WITH ALTERNATE DATE
select * from SE_ROOT_DBF where M_SE_LABEL = 'PERU 8.2 0826  '; -- check field M_SE_MARKET='DEUDA PEN' and M_SE_TRDCL='PEN BONDS'
select * from SE_TRDC_DBF where M_SE_TRDCL='PEN BONDS ';
select * from SE_TRDS_DBF where M_SE_TCS_L='STK 3,3   ';
select * from SE_TRDS_DBF where M_SE_TCS_L='STK 3,3 SS';
select * from SE_TRDC_DBF where M_SE_TRDCL='PEN BONDS0';
-- correction to duplicate settlement and trading clause then assign these new objects to bonds
---- duplicate the original settlement information
insert into SE_TRDS_DBF(M_SE_TCS_L, M_SE_TCS_T, M_SE_SET, M_SE_O_SET_F, 
M_SE_FS_RSF0, M_SE_FS_RSF1, M_SE_FS_RS0, M_SE_FS_RS1, M_SE_DCONV, 
M_SE_CLEAR, M_SE_SEC_LS0, M_SE_SEC_LS1, M_SE_MARG_F, M_SE_EX_D_F, 
M_SE_EX_D_R, M_SE_SHIFT, M_SE_CACONV, M_SE_SEC_LSF, M_SE_SEC_OLS, 
M_SE_DPBTS_F, M_SE_EX_C_F, M_SE_EX_C_R)
------ be carefull M_SE_TCS_L is only 10 chars length
select 'STK 3,3 SS',M_SE_TCS_T, M_SE_SET, M_SE_O_SET_F,
M_SE_FS_RSF0, M_SE_FS_RSF1, M_SE_FS_RS0, M_SE_FS_RS1, M_SE_DCONV, 
M_SE_CLEAR, M_SE_SEC_LS0, M_SE_SEC_LS1, M_SE_MARG_F, M_SE_EX_D_F, 
M_SE_EX_D_R, M_SE_SHIFT, M_SE_CACONV, M_SE_SEC_LSF, M_SE_SEC_OLS, 
M_SE_DPBTS_F, M_SE_EX_C_F, M_SE_EX_C_R
from SE_TRDS_DBF
where M_SE_TCS_L = 'STK 3,3   ';
---- duplicate the original trading clause pointing t0
---- the settlement created above
insert SE_TRDC_DBF(M_SE_TRDCL, M_SE_GROUP, M_SE_TYPE, M_SE_LO_F, 
M_SE_OO_F, M_SE_FD, M_SE_TCS_L, M_SE_TCQ_L, M_SE_CUR)
------ be carefull M_SE_TRDCL is only 10 chars length
select 'PEN BONDS0',M_SE_GROUP, M_SE_TYPE, M_SE_LO_F, 
M_SE_OO_F, M_SE_FD, 'STK 3,3 SS', M_SE_TCQ_L, M_SE_CUR
from SE_TRDC_DBF
where M_SE_TRDCL = 'PEN BONDS ';
---- modify the bond to point to the new trading clause
update SE_ROOT_DBF
set M_SE_TRDCL = 'PEN BONDS0'
where M_SE_LABEL = 'PERU 8.2 0826  ';

select bond.M_SE_LABEL, tc.M_SE_TRDCL, stl.M_SE_TCS_L, udf.M_ALT_CONV_D -- list bond its alternate date, trading clause and settlement
from SE_HEAD_DBF head 
    join SE_ROOT_DBF bond on bond.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDC_DBF tc on tc.M_SE_TRDCL = bond.M_SE_TRDCL
    join TABLE#DATA#SECURITI_DBF udf on udf.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDS_DBF stl on tc.M_SE_TCS_L = stl.M_SE_TCS_L
where head.M_SE_GROUP = 'Bond'
    and udf.M_ALT_CONV_D IS NOT NULL -- bond having an alternate
    and bond.M_SE_DE <> 'Y'-- bond is not dead
    and stl.M_SE_TCS_L='STK 3,3' -- on a specific settlement
order by stl.M_SE_TCS_L,bond.M_SE_LABEL;
    

select stl.M_SE_TCS_L, udf.M_ALT_CONV_D,1 'count'-- list distinct settlement / alternate date
from SE_HEAD_DBF head 
    join SE_ROOT_DBF bond on bond.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDC_DBF tc on tc.M_SE_TRDCL = bond.M_SE_TRDCL
    join TABLE#DATA#SECURITI_DBF udf on udf.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDS_DBF stl on tc.M_SE_TCS_L = stl.M_SE_TCS_L
where head.M_SE_GROUP = 'Bond'
    and udf.M_ALT_CONV_D IS NOT NULL -- bond having an alternate
    and bond.M_SE_DE <> 'Y' and head.M_SE_MAT > (select max(M_DATE) from TRN_DSKD_DBF)-- bond is not dead
order by stl.M_SE_TCS_L, udf.M_ALT_CONV_D;
--group by tc.M_SE_TRDCL, stl.M_SE_TCS_L, udf.M_ALT_CONV_D;
    --and stl.M_SE_TCS_L='STK 3,3'; -- on a specific settlement;
    
select udf.M_ALT_CONV_D, count(*) -- count the number of bonds alternate date for a specific settlement
from SE_HEAD_DBF head 
    join SE_ROOT_DBF bond on bond.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDC_DBF tc on tc.M_SE_TRDCL = bond.M_SE_TRDCL
    join TABLE#DATA#SECURITI_DBF udf on udf.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDS_DBF stl on tc.M_SE_TCS_L = stl.M_SE_TCS_L
where head.M_SE_GROUP = 'Bond'
    and udf.M_ALT_CONV_D IS NOT NULL -- bond having an alternate
    and bond.M_SE_DE <> 'Y' -- bond is not dead
    and stl.M_SE_TCS_L='STK 3,3' -- on a specific settlement
group by udf.M_ALT_CONV_D;

from SE_HEAD_DBF head 
    join SE_ROOT_DBF bond on bond.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDC_DBF tc on tc.M_SE_TRDCL = bond.M_SE_TRDCL
    join TABLE#DATA#SECURITI_DBF udf on udf.M_SE_LABEL = head.M_SE_LABEL
    join SE_TRDS_DBF stl on tc.M_SE_TCS_L = stl.M_SE_TCS_L;

-- from Xavi
SELECT A.M_SE_LABEL ,S.M_SE_CODE,S.M_SE_MAT,S.M_SE_DE,S.M_SE_DED ,A.M_SE_DE,A.M_SE_DED,A.M_SE_MARKET, A.M_SE_TRDCL, A.M_SE_TCS_L,B.M_SE_TCS_L, T.M_ALT_CONV_D 
FROM SE_ROOT_DBF A, SE_TRDC_DBF B,SE_HEAD_DBF S,TABLE#DATA#SECURITI_DBF T 
WHERE A.M_SE_TRDCL =B.M_SE_TRDCL AND A.M_SE_LABEL=S.M_SE_LABEL AND A.M_SE_LABEL*=T.M_SE_LABEL AND S.M_SE_GROUP='Bond' 
and A.M_SE_LABEL='ACAFP 7 0849';

-- analysis based on Xavi's remark
--- store in a table the bond that overide the settlement clause in SE_ROOT_DBF
drop table sst_bnd_tcs_l_override;
select head.M_SE_LABEL as 'bond label', bond.M_SE_TCS_L as 'settlement', udf.M_ALT_CONV_D as 'alternate date'
into sst_bnd_tcs_l_override
from SE_HEAD_DBF head 
    join SE_ROOT_DBF bond on bond.M_SE_LABEL = head.M_SE_LABEL
    join TABLE#DATA#SECURITI_DBF udf on udf.M_SE_LABEL = head.M_SE_LABEL
where head.M_SE_GROUP = 'Bond'
    and udf.M_ALT_CONV_D IS NOT NULL -- bond having an alternate
    and bond.M_SE_DE <> 'Y' -- bond is not dead
    and bond.M_SE_TCS_L <> '';
-- case 716359
select count(*) from ERM_SA_RRAO_INP_REP;
select top 50 * from ERM_SA_RRAO_INP_REP;
-- case 713170
select M_LABEL from MX_USER_DBF;
select top 10 * from NPD_HDR_DBF;
select M_LABEL,M_USER from NPD_HDR_DBF where M_USER not in (select M_LABEL from MX_USER_DBF) and M_USER <> '' group by M_LABEL,M_USER;
select M_LABEL,M_USER from NPD_HDR_DBF where M_OWNER not in (select M_LABEL from MX_USER_DBF) and M_OWNER <> '' group by M_LABEL,M_USER;
-- decypher BBVA 2.11 DB
create index TRN_CPDF_CS0 on TRN_CPDF_DBF(M_ID);
create unique clustered index TRN_CPDF_ND0 on TRN_CPDF_DBF(M_LABEL);
create index TRN_CPDF_ND1on TRN_CPDF_DBF(M_ID, M_LABEL);
select count(*) from TRN_CPDF_NEW;