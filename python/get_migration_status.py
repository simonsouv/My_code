import xml.etree.ElementTree as etree
import shlex, subprocess, os, sys
from datetime import datetime, timedelta

#This script is tested with python python278_64
#In order to make it work you need to execute first those two commands in the shell launching the script
#
#export PYTHONHOME=/nettools/python_release/python278_64/
#export LD_LIBRARY_PATH=/nettools/python_release/python278_64/lib/:$LD_LIBRARY_PATH

def get_db_info(rootTree):
    """
    this method retrieves database information from dbsource.mxres
    """
    global db_type, db_server, db_database, db_user

    db_type = rootDB.find('.//DbServerType').text
    db_server = rootDB.find('.//DbServerOrServiceName').text
    db_database = rootDB.find('.//DbDatabaseOrSchemaName').text
    db_user = rootDB.find('.//DbUser').text
    print 'DB VENDOR: '+db_type
    print 'DB SERVER: '+db_server
    print 'DB NAME  : '+db_database

def define_sql_query():
    """
    This method generates the sql code that will be executed on sybase or oracle
    Please note that the field MESSAGE_TIME_STAMP of time datetime
    will be output with format yy/mm/dd HH:mm:ss
    The field retrieved are: MESSAGE_ID, ,MESSAGE_TIME_STAMP, PATH, STEP, GSTATUS, BUILD_ID, LOG_ID, MX_BUILD_ID, TARGET
    """
    global filename_sql,file_sql,filename_res
    filename_res='/tmp/sql_mxodr.res'
    try:
        filename_sql='/tmp/sql_mxodr.sql'
        file_sql=open(filename_sql,'w')
    except:
        print 'Cannot open file {} in write mode'.format(filename_sql)
        exit(-1)

    if db_type =='sybase':
        file_sql.write("set nocount on\n")
        file_sql.write("go\n")
        file_sql.write("select str(MESSAGE_ID)+'|'+convert(varchar(30),MESSAGE_TIME_STAMP,21)+'|'+ltrim(PATH)+'|'+ltrim(STEP)+'|'+ltrim(GSTATUS)+'|'+ltrim(BUILD_ID)+'|'+ltrim(LOG_ID)+'|'+ltrim(MX_BUILD_ID)+'|'+ltrim(TARGET)+'|' from MXODR_ASSEMBLY_LOG order by MESSAGE_ID\n")
        file_sql.write('go\n')
        file_sql.write('exit\n')
    else:
        file_sql.write('set lines 300;\n')
        file_sql.write('set pagesize 0;\n')
        file_sql.write('set feed off;\n')
        file_sql.write('set colsep "|";\n')
        file_sql.write('set trim on;\n')
        file_sql.write('set heading off;\n')
        file_sql.write('spool '+filename_res+';\n')
        file_sql.write("select TO_CHAR(MESSAGE_ID)||'|'||TO_CHAR(MESSAGE_TIME_STAMP,'YY/MM/DD HH24:MI:SS')||'|'||TRIM(PATH)||'|'||TRIM(STEP)||'|'||TRIM(GSTATUS)||'|'||TRIM(BUILD_ID)||'|'||TRIM(LOG_ID)||'|'||TRIM(MX_BUILD_ID)||'|'||TRIM(TARGET)||'|' from MXODR_ASSEMBLY_LOG order by MESSAGE_ID\n")
        file_sql.write(';\n')
        file_sql.write('exit;\n')
    file_sql.close()

def get_audit():
    try:
        devnull=open('/dev/null','w')
    except:
        print 'Cannot write to /dev/null'
        exit(-1)

    if db_type == 'sybase':
        cmd_line='isql -b -n -i ' + filename_sql + ' -o ' + filename_res + ' -U ' + db_user + ' -P INSTALL -S ' + db_server + ' -D '+db_database + ' -w300'
        print 'Command line called is: '+cmd_line+'\n'
    else:
        cmd_line='sqlplus '+db_user+'/'+db_user+'@'+db_server+' @'+filename_sql
        print 'Command line called is: '+cmd_line+'\n'

    try:
        arguments=shlex.split(cmd_line) #shlex.split is used to correctly split/tokenize the command line
        p = subprocess.Popen(arguments, stdout=devnull) #it's better to use Popen with arguments in forms of tokens instead of a string
        p.communicate()
    except:
        print 'PROBLEM EXECUTING '+cmd_line
        exit(-2)

    print 'CONTENT OF TABLE MXODR_ASSEMBLY_LOG DUMPED IN FILE: '+filename_res

def analyze_timing():
    """
    analyze_timing function parses the contennt of MXODR_ASSEMBLY_LOG saved in file /tmp/sql_mxodr.res
    Each step of the richCLient is log two time in MXODR_ASSEMBLY_LOG
    -One time to log the start of the step
    -One time to log the end of the step
    Note that the step duration is appended to the original log in format hh:mm:ss and also in epoch format
    Note that the client name is also appended
    """
    cumul_duration = timedelta()
    cumul_duration_secs = 0
    filename_final='/tmp/richlClient_audit.log'
    try:
        file_mxodr=open(filename_res,'r')
    except:
        print 'Cannot open file '+filename_res
        exit(-3)

    try:
        file_final=open(filename_final,'w')
    except:
        print 'Cannot open file '+filename_final
        exit(-4)
    
    tmp_l=file_mxodr.readline()
    #print tmp_l,type(tmp_l)
    #print tmp_l[4],type(tmp_l[4])

    while tmp_l != '':
        if tmp_l.split('|')[4] == 'L': #the line reads is the log of the initiation of a step.
            #copy the current line in start_l which will be used later
            start_l = tmp_l
            #get the date and time which is in the 2nd field in the string representing one line of log and store it in a datetime variable
            #because it's easier to calculate elapse time with datetime objects
            dt_tmp_time = datetime.strptime(tmp_l.split('|')[1],"%y/%m/%d %H:%M:%S")
        else: #the line reads is the log of the end of the step
            end_l = tmp_l
            dt_tmp2_time = datetime.strptime(tmp_l.split('|')[1],"%y/%m/%d %H:%M:%S")
            #let's compute the duration of the step
            dt_step_duration = dt_tmp2_time - dt_tmp_time
            ep_step_duration =  dt_step_duration.total_seconds()
            #let's compute the cumulated execution
            cumul_duration += dt_step_duration
            cumul_duration_secs += ep_step_duration
            #print cumul_duration, type(cumul_duration), cumul_duration_secs, type(cumul_duration_secs)

            #replace the status 'launched' (L) in start_l with the final status of the step
            #to do so, we convert start_l which is a string to a list of objects
            final_l =start_l.split('|')
            #remove the last element as it contains only space
            del final_l[len(final_l)-1]
            #we change the status of the step by getting the final status from end_l
            final_l[4] = end_l.split('|')[4]
            #print dt_step_duration, type(dt_step_duration)

            #add in final_l list the duration of the step in time and epoch representation
            final_l.extend([str(dt_step_duration),str(ep_step_duration),str(cumul_duration),str(cumul_duration_secs),client])
            #print final_l, type(final_l,) 

            #write the list final_l in file file_final
            #because the write method accept only a str we need to concatenate its content in a string
            #'|'.join(final_l) means concatenate each element of final_l with | as separator
            file_final.write('|'.join(final_l))
            file_final.write('\n')
        tmp_l=file_mxodr.readline()
    print 'ANALYSIS OF MXODR_ASSEMBLY_LOG DONE, OUTPUT FILE IS ', filename_final
    file_mxodr.close()
    file_final.close()

def inject_elastic() :
    """
    This method reads the input file resulting from the analysis of the audit and will inject the data in elastic
    By default we read the file generated by method analyze_timing() which is /tmp/richlClient_audit.log
    """
    try:
        elastic_log = '/tmp/inject_elastic.log'
        f_log = open(elastic_log,'w')
    except:
        print 'Cannot write to ',elastic_log
        exit(-1)

    filename = '/tmp/richlClient_audit.log'
    try:
        f = open(filename, 'r')
    except:
        print "Cannot read file ", filename
        exit (-4)
    #elastic_docs contains the list of fiels of the document to be inserted in elastic search
    elastic_docs = [ 'msg_id ', 'msg_timestamp', 'path', 'step', 'status', 'build_id', 'log_id', 'mx_build_id', 'target','duration','duration_secs','cumul_duration','cumul_duration_secs','client']
    #cpt = 0
    #args = ''
    #print elastic_docs
    cur_l = f.readline()
    while cur_l != '':
        cur_l = cur_l.split('|')
        cpt = 0
        args = ''
        #print cur_l
        for i in elastic_docs:
            args += '"' + i + '" : "' + cur_l[cpt].lstrip().rstrip() +'",'
            cpt += 1
        args = args [:-1]
        #print args
        cmd_line="""curl -ifX  POST 'http://mx2597vm:9200/index_simon/richclient/' -d '{"""+args+"""}'"""
        #print cmd_line

        try:
            arguments=shlex.split(cmd_line)
            #p = subprocess.Popen(arguments, stdout=devnull)
            #p = subprocess.Popen(arguments)
            #p.communicate()
            subprocess.check_call(arguments, stdout=f_log, stderr=f_log)
            print 'Information inserted in elastic'
        except:
            print "Probem executing command: ",cmd_line
        cur_l = f.readline()
    f.close()

#
#
#    MAIN PROGRAM
#
#
if __name__ =="__main__":
    """
    This program is an attempt to get the migration status
    """

    db_type = db_server = db_database = db_user = filename_sql = file_sql = filename_res = ''

    #print sys.argv
    if len(sys.argv) < 2:
        print "Missing arguments"
        print "Script usage is: get_migration_status.py <client name>"
        print "/nettools/python_release/python278_64/bin/python /tmp/get_migration_status.py dz"
        exit(-1)

    client=sys.argv[1]

    print 'CURRENT DIRECTORY IS: '+ os.getcwd()
    # step 1: open file containing the db informations
    try:
        db_filename='fs/public/mxres/common/dbconfig/dbsource.mxres'
        db_info = open(db_filename,'r')
        #print db_info, type(db_info)
    except:
        print 'File {} does not exist'.format(db_filename)
        exit(-3)
        
    # step 2 parse the db file to get DB type, DB server, DB name and credentials
    treeDB = etree.parse(db_info)
    rootDB= treeDB.getroot()
    #print rootDB,type(rootDB)
    #for child in rootDB:
    #    print child.tag
    
    # get the database informations
    get_db_info(rootDB)
    #print db_type, type(db_type), db_server, type(db_server), db_database, type(db_database), db_user, type(db_user)
    
    #prepare the sql file containing the sql to be executed
    define_sql_query()
    
    #test the content of the file is correct
    #file_sql=open(filename_sql,'r')
    #print file_sql.readlines()
    
    #execute the sql
    get_audit()
    print 'CONTENT OF TABLE MXODR_ASSEMBLY_LOG DUMPED IN FILE: '+filename_res
    
    analyze_timing()
    
    inject_elastic()
