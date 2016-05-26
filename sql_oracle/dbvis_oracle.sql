@desc t;
-- index definition
select u1.TABLE_NAME, u1.TABLE_TYPE, u1.INDEX_NAME, u1.INDEX_TYPE, u1.UNIQUENESS, u2.COLUMN_NAME, u2.COLUMN_LENGTH, u2.DESCEND, u2.COLUMN_POSITION
from user_indexes u1 join user_ind_columns u2 on u1.INDEX_NAME = u2.INDEX_NAME
where u1.TABLE_NAME='ACT_DYN_DBF'
order by u1.INDEX_NAME,u2.COLUMN_POSITION;

-- statistics information
-- dbms_stats.gather_table_stats('MXPRD_JAN16','ACT_DYN_DBF',degree=>'AUTO_DEGREE'); -- command to gather statistics on a table (search man page for all possible args)
-- dbms_stats.gather_index_stats(ownname =>'MXPRD_JAN16', indname => 'ACT_DYN_ND0'); -- command to gather statistics on an index (search man page for all possible args)
select TABLE_NAME, OBJECT_TYPE, NUM_ROWS, LAST_ANALYZED, USER_STATS, STALE_STATS from USER_TAB_STATISTICS where table_name='T'; -- USER_TAB_STATISTICS displays optimizer statistics for the tables owned by the current user, especially check column LAST_ANALYZED and STALE_STATS (check table definition for additional field to display)
select * from USER_TAB_COLUMNS where TABLE_NAME='T'; -- USER_TAB_COLUMNS describes the columns of the tables,, check column HISTOGRAM to see whether statistics exist or not
select * from USER_TAB_COL_STATISTICS where TABLE_NAME='T'; -- USER_TAB_COL_STATISTICS contains column statistics and histogram information extracted from "USER_TAB_COLUMNS" (check table definition for additional field to display)
select INDEX_NAME,STATUS, LAST_ANALYZED, CLUSTERING_FACTOR, NUM_ROWS from USER_INDEXES where INDEX_NAME like 'ACT_BAT_%'; -- check if index statistics are up-to-date

-- create index on a table
create index ACT_DYN_SST_ND0 on ACT_DYN_DBF(M_OUTPUT);

select OBJECT_NAME from USER_OBJECTS where OBJECT_NAME like 'STPFC%' and OBJECT_TYPE='TABLE';

select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFG_RELATIONSHIP,M_RFD_TABLE_NAME,M_RFD_FORMULA,M_RFD_RELATIONSHIP from RDBCNSTR_DBF where M_RFD_TABLE_NAME='TRN_CPDF_DBF' and M_RFD_FORMULA='M_LABEL';
select M_RFG_TABLE_NAME,M_RFG_FORMULA,M_RFG_RELATIONSHIP,M_RFD_TABLE_NAME,M_RFD_FORMULA,M_RFD_RELATIONSHIP from RDBCNSTR_DBF where M_RFG_TABLE_NAME='TRN_CPDF_DBF' and M_RFG_FORMULA='M_LABEL';

