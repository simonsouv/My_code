# _*_ coding:Utf8 _*_   #define the encoding type

#This script is tested with python python278_64
#In order to make it work you need to execute first those two commands in the shell launching the script
#
#export PYTHONHOME=/nettools/python_release/python278_64/
#export LD_LIBRARY_PATH=/usr/sfw/lib/sparcv9:/nettools/python_release/python278_64/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH_64=/usr/sfw/lib/sparcv9:/nettools/python_release/python278_64/lib:$LD_LIBRARY_PATH_64

import migop_generic_method as mg

def main():
    db_info = mg.get_db_info_from_dbsource('/mx552zn/apps/CONV_201602/fs/public/mxres/common/dbconfig/dbsource.mxres')
    print db_info
    #db_sql = mg.sql_statement_mxodr_assembly('sybase')
    #print db_sql
    #mg.exec_sql(db_info,db_sql)
    #db_sql = mg.sql_statement_sybase_device_info()
    #print db_sql
    #mg.exec_sql(db_info,db_sql)
    db_sql = mg.sql_statement_sybase_dump_mapping('/net/fs8612/alloc0001557/dump/BBVA/dump_656828/','BBVA_TMP_MX_20160122_1224.cmp',4)
    #print db_sql
    mg.exec_sa_sql(db_info,db_sql)
    

# MAIN PROGRAM
#
if __name__ =="__main__":
    main()
