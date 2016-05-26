# _*_ coding:Utf8 _*_   #define the encoding type

#This script is tested with python python278_64
#In order to make it work you need to execute first those two commands in the shell launching the script
#
#export PYTHONHOME=/nettools/python_release/python278_64/
#export LD_LIBRARY_PATH=/usr/sfw/lib/sparcv9:/nettools/python_release/python278_64/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH_64=/usr/sfw/lib/sparcv9:/nettools/python_release/python278_64/lib:$LD_LIBRARY_PATH_64

import migop_generic_method as mg
import getopt, sys

def usage():
    print 'ERROR in calling the script'
    print 'Syntax : /nettools/python_release/python278_64/bin/python /tmp/generate_sybase_load_command.py -S <DATASERVER> -P <PATHTO THE DUMP> -F <DUMPFILE NAME> -N <NUMBER OF STRIPE> -T <DATABASE TO CREATE'

def main ():
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'S:P:F:N:T:')
    except:
        usage()
        sys.exit(-1)

    dServer, dBase, dDump, dPath, dStripe= '', '', '', '', ''
    for o,a in opts:
        if o == '-S':
            dServer = a
        elif o == '-P':
            dPath = a
        elif o == '-F':
            dDump = a
        elif o == '-N':
            dStripe = a
        elif o == '-T':
            dBase = a
    
    db_info, db_dump = {}, {}
    db_info['db_type'] = 'sybase'
    db_info['db_server'] = dServer
    db_info['db_database'] = 'tempdb'
    db_info['db_user'] = 'INSTAL'
    db_dump['path'] = dPath
    db_dump['file'] = dDump
    db_dump['stripe'] = int(dStripe)

    db_info['db_version'] = mg.get_syb_version(db_info)
    #print db_info['db_version']
    #get the db information from the environment provided in args of the method
    #db_info = mg.get_db_info_from_dbsource('/mx552zn/apps/CONV_201602/fs/public/mxres/common/dbconfig/dbsource.mxres')

    #generate the sql that will retrieve sybase device information and execute it
    print "-- get informations about sybase devices (name, size, used, free) \n"
    db_sql_dev = mg.sql_statement_sybase_device_info(db_info)
    mg.exec_sql(db_info,db_sql_dev)

    #generate the load database with headeronly command to get the segmap and execute it
    print "-- get the segmap from the dump provided \n"
    db_sql_load = mg.sql_statement_sybase_dump_mapping(db_dump['path'],db_dump['file'],db_dump['stripe'])
    mg.exec_sa_sql(db_info,db_sql_load)

    #parse the list of device and resturn a dictionay of devices with free space
    print "-- get the list of devices with free space \n"
    free_dev = mg.get_sybase_device_with_free_space(db_sql_dev['sql_output'])
    #print free_dev
    print "-- checking for the availability to create the database \n"
    mg.generate_sybase_create_command(dBase,free_dev,db_sql_load['sql_output'])


# MAIN PROGRAM
#
if __name__ =="__main__":
    main()

