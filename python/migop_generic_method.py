import xml.etree.ElementTree as etree
import shlex, subprocess, os, sys, re, logging
from datetime import datetime, timedelta

# This python contains several method that could be used in other python scripts.
# The idea is not to rewrite code again and again
#

def get_db_info_from_dbsource(dbsource_file):
    """
    this method retrieves database information from dbsource.mxres provided as a parameter
    """
    try:
        f_dbsource = open(dbsource_file,'r')
    except:
        print 'Cannot open dbsource file {}'.format(dbsource_file)
	sys.exit(-1)
    d_db_info = {}
    treeDB = etree.parse(f_dbsource)
    rootDB = treeDB.getroot()
    d_db_info['db_type'] = rootDB.find('.//DbServerType').text
    d_db_info['db_server'] = rootDB.find('.//DbServerOrServiceName').text
    d_db_info['db_database'] = rootDB.find('.//DbDatabaseOrSchemaName').text
    d_db_info['db_user'] = rootDB.find('.//DbUser').text
    print 'DB VENDOR: '+d_db_info['db_type']
    print 'DB SERVER: '+d_db_info['db_server']
    print 'DB NAME  : '+d_db_info['db_database']
    return d_db_info


def sql_statement_mxodr_assembly(db_type):
    """
    This method generates the sql code that will be executed on sybase or oracle
    Please note that the field MESSAGE_TIME_STAMP of time datetime
    will be output with format yy/mm/dd HH:mm:ss
    The field retrieved are: MESSAGE_ID, ,MESSAGE_TIME_STAMP, PATH, STEP, GSTATUS, BUILD_ID, LOG_ID, MX_BUILD_ID, TARGET
    """
    d_sql_file = {}
    d_sql_file['sql_input'] = '/tmp/sql_mxodr.sql'
    d_sql_file['sql_output'] =  '/tmp/sql_mxodr.res'
    filename_res=d_sql_file['sql_output']
    try:
        filename_sql=d_sql_file['sql_input']
        file_sql=open(filename_sql,'w')
    except:
        print 'Cannot open file {} in write mode'.format(filename_sql)
        sys.exit(-1)

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
        file_sql.write('spool '+d_sql_file['sql_output']+';\n')
        file_sql.write("select TO_CHAR(MESSAGE_ID)||'|'||TO_CHAR(MESSAGE_TIME_STAMP,'YY/MM/DD HH24:MI:SS')||'|'||TRIM(PATH)||'|'||TRIM(STEP)||'|'||TRIM(GSTATUS)||'|'||TRIM(BUILD_ID)||'|'||TRIM(LOG_ID)||'|'||TRIM(MX_BUILD_ID)||'|'||TRIM(TARGET)||'|' from MXODR_ASSEMBLY_LOG order by MESSAGE_ID\n")
        file_sql.write(';\n')
        file_sql.write('exit;\n')
    file_sql.close()
    return d_sql_file


def sql_statement_sybase_device_info(d_db_info):
    """
    This method generates the sql code that will be executed on sybase to get devices information
    """
    d_sql_file = {}
    d_sql_file['sql_input'] = '/tmp/sql_devices.sql'
    d_sql_file['sql_output'] =  '/tmp/sql_devices.res'
    filename_res=d_sql_file['sql_output']
    try:
        filename_sql=d_sql_file['sql_input']
        file_sql=open(filename_sql,'w')
    except:
        print 'Cannot open file {} in write mode'.format(filename_sql)
        sys.exit(-1)

    file_sql.write("set nocount on\n")
    file_sql.write("go\n")

    if d_db_info['db_version'] > '13' :
        file_sql.write("declare @numpgsmb float \n declare @nummxpgsmb float \n select @numpgsmb = (1048576. / @@pagesize) \n select @nummxpgsmb = (1048576. / @@maxpagesize) \n")
        file_sql.write("select T1.name, convert(int,1+((T1.high - T1.low ) / @numpgsmb)) as 'size', convert(int,isnull(T2.used,0) / @nummxpgsmb) as 'used', convert(int,1+((T1.high - T1.low ) / @numpgsmb)) - convert(int,isnull(T2.used,0) / @nummxpgsmb) as 'free' \n")
        file_sql.write("from master..sysdevices T1 left join (select vdevno,sum(size) as 'used' from master..sysusages group by vdevno) T2 on T1.vdevno = T2.vdevno where T1.name like 'MUREX%' order by T1.name \n")
    else:
        file_sql.write("select T1.logical_name, T1.size, sum(T1.reserved) as used, (T1.size - sum(T1.reserved)) as left from \n")
        file_sql.write("(select logical_name = substring(d.name, 1, 12), size = (d.high - d.low + 1) * 2 / 1024, \n")
        file_sql.write("reserved = isnull(u.size,0) * 4 / 1024 from master.dbo.sysdevices d left join master.dbo.sysusages u \n")
        file_sql.write("on u.vstart / power(2, 24)= d.low / power(2, 24) where d.status & 2 = 2 and d.name like  'MUREXFS%') \n")
        file_sql.write("T1 group by T1.logical_name, T1.size \n")
    file_sql.write('go\n')
    file_sql.write('exit\n')
    file_sql.close()
    return d_sql_file


def sql_statement_sybase_dump_mapping(dump_path, dump_file, dump_stripe):
    """
    this method generates the SQL statement to load a database with headeronly option
    """
    d_sql_file = {}
    d_sql_file['sql_input'] = '/tmp/sql_get_segmap.sql'
    d_sql_file['sql_output'] =  '/tmp/sql_get_segmap.res'
    filename_res=d_sql_file['sql_output']
    try:
        filename_sql=d_sql_file['sql_input']
        file_sql=open(filename_sql,'w')
    except:
        print 'Cannot open file {} in write mode'.format(filename_sql)
        sys.exit(-1)

    if (dump_stripe < 2):
        file_sql.write("load database TEST from 'compress::" + dump_path + dump_file + "' \n")
    else:
        stripe_number = range(2, dump_stripe + 1, 1)
        file_sql.write("load database TEST from 'compress::" + dump_path + dump_file + ".1'" + "\n") 
        for i in stripe_number:
            file_sql.write("stripe on 'compress::" + dump_path + dump_file + '.' + str(i) + "'" + "\n")

    file_sql.write("with headeronly \n")
    file_sql.write("go \n")
    file_sql.write("exit \n")
    file_sql.close()
    return d_sql_file


def get_syb_version(d_dbserver):
    """
    this method will retrieve the Sybase version
    """
    s_input = '/tmp/syb_vers.sql'
    s_output = '/tmp/syb_vers.log'
    try:
        f_input = open(s_input,'w')
    except:
        print 'Cannot open file {} in write mode'.format(s_input)
        sys.exit(-2)
    try:
        devnull=open('/dev/null','w')
    except:
        print 'Cannot write to /dev/null'
        exit(-1)

    f_input.write("select @@version \n")
    f_input.write("go \n")
    f_input.write("exit \n")
    f_input.close()
    cmd_line = 'isql -b -n -i ' + s_input + ' -o ' + s_output + ' -U ' + d_dbserver['db_user'] + ' -P INSTALL -S ' + d_dbserver['db_server'] + ' -D '+ d_dbserver['db_database'] + ' -w300'
    try:
        arguments=shlex.split(cmd_line) #shlex.split is used to correctly split/tokenize the command line
        p = subprocess.Popen(arguments, stdout=devnull) #it's better to use Popen with arguments in forms of tokens instead of a string
        p.communicate()
    except:
        print 'PROBLEM EXECUTING '+cmd_line
        sys.exit(-2)
    f_output = open(s_output,'r')
    while True:
        line = f_output.readline()
        if line == '':
            break
        #match =  re.search('^ Adaptive Server Enterprise\/\S+\/',line)
        match =  re.search('\d\S+\/',line)
        if match:
            s = re.sub('/','',match.group())
    return s
 

def exec_sql(d_dbserver,d_sql):
    """
    this method executes sql statements contained in a file provided in object d_sql on database provided in d_dbserver
    """
    try:
        devnull=open('/dev/null','w')
    except:
        print 'Cannot write to /dev/null'
        exit(-1)

    if d_dbserver['db_type'] == 'sybase':
        cmd_line='isql -b -n -i ' + d_sql['sql_input'] + ' -o ' + d_sql['sql_output'] + ' -U ' + d_dbserver['db_user'] + ' -P INSTALL -S ' + d_dbserver['db_server'] + ' -D '+ d_dbserver['db_database'] + ' -w300'
    else:
        cmd_line='sqlplus '+ d_dbserver['db_user'] +'/'+ d_dbserver['db_user'] +'@'+ d_dbserver['db_server'] +' @'+ d_sql['sql_input']

    print 'Command line called is: '+cmd_line
    try:
        arguments=shlex.split(cmd_line) #shlex.split is used to correctly split/tokenize the command line
        p = subprocess.Popen(arguments, stdout=devnull) #it's better to use Popen with arguments in forms of tokens instead of a string
        p.communicate()
    except:
        print 'PROBLEM EXECUTING '+cmd_line
        sys.exit(-2)

    print 'result of sql orders in file {} are in file {}: '.format(d_sql['sql_input'],d_sql['sql_output'])


def exec_sa_sql(d_dbserver,d_sql):
    """
    this method executes sql statements 'as sa' contained in a file provided in object d_sql on database provided in d_dbserver
    """
    try:
        devnull=open('/dev/null','w')
    except:
        print 'Cannot write to /dev/null'
        exit(-1)

    if d_dbserver['db_type'] == 'sybase':
        cmd_line='isql -b -n -i ' + d_sql['sql_input'] + ' -o ' + d_sql['sql_output'] + ' -U sa -P  -S ' + d_dbserver['db_server'] + ' -w300'
    else:
        cmd_line='sqlplus '+ d_dbserver['db_user'] +'/'+ d_dbserver['db_user'] +'@'+ d_dbserver['db_server'] +' @'+ d_sql['sql_input']

    print 'Command line called is: '+cmd_line
    try:
        arguments=shlex.split(cmd_line) #shlex.split is used to correctly split/tokenize the command line
        p = subprocess.Popen(arguments, stdout=devnull) #it's better to use Popen with arguments in forms of tokens instead of a string
        p.communicate()
    except:
        print 'PROBLEM EXECUTING '+cmd_line
        sys.exit(-2)

    print 'result of sql orders in file {} are in file {}: '.format(d_sql['sql_input'],d_sql['sql_output'])


def get_sybase_device_with_free_space(f_input):
    """
    this method reads a file containing the list of devices and returns a dictionary
    of devices having free space
    """
    try:
        list_dev = open(f_input,'r')
    except:
        print 'cannot open file {}, exit'.format(f_input)
        sys.exit(-2)

    d_free_dev = {}
    for line in list_dev:
        line = line.rstrip()
        if re.search("^ MUREXFS.* [1-9][0-9]+$", line):
            line = line.split()
            d_free_dev[line[0]] = line[len(line)-1]
    return d_free_dev


def generate_sybase_create_command(s_target_base,d_free_dev, f_segmap):
    """
    this method will read the segmap of a dump and generate the create database command 
    to have a clean separation of data and log
    """
    try:
        list_segmap = open(f_segmap,'r')
    except:
        print 'cannot open file {}, exit'.format(f_segmap)
        sys.exit(-2)

    logging.basicConfig(filename='load_db_command.log', filemode='w', format='%(asctime)s:%(levelname)s:%(message)s', level=logging.DEBUG)
    d_local_free_dev = {k:v for k,v in d_free_dev.items()} # create a copy of free_device because we'll change its content
    l_dev_scan = []  # list containing the devices already scanned
    l_dev_used = []  # list containing the devices already used
    l_dev_data = []  # list containing the devices used as data
    l_dev_log = []   # list containing the devices used as log
    d_sql_order = {} # dictionary that will contain the devices order for the create database statement
    no_space = False
    maxpagesize = 4096
    pgToMb = 1048576. / maxpagesize

    # scan each line of the file and keep only the line starting with segmap. 
    # stop the scan if no_space or reach end of line
    while not no_space: 
        line = list_segmap.readline()
        if line == '' : # test if we reach the end of line
            break
    #for line in list_segmap: 
        line = line.rstrip()
        if re.search("^segmap\: ", line):
            line =  line.replace('lsize=','').replace('0x0000000','').split()
            seg_type, seg_size = line[1], int(float(line[len(line)-2]) / pgToMb)
            logging.info('current segmap is of type %s with size %s',seg_type,seg_size)
            dev_found = False
            for k,v in d_local_free_dev.items() : # search for a device having free space
                if int(v) >= int(seg_size) : # found a device with enough space
                    logging.info('%s has %s free space that fits the request of %s',k,v,seg_size)
                    # check if the key exists in d_dev_used, meaning it's already used
                    if k in l_dev_used: # the device is already used
                        logging.info('%s is already used as data or log',k)
                        # check if the used device is of the same type as the segmap candidate
                        if ((k in l_dev_data) and seg_type == '3') or ((k in l_dev_log) and seg_type == '4'): 
                            # the current segmap is of type data and device candidate is also used as data 
                            # so we add it in the dictionary for the create database statement
                            logging.info('%s can be reused',k)
                            logging.info('adding %s to d_sql_order',k)
                            d_sql_order[len(d_sql_order)] = k+'='+str(seg_size)
                            logging.info('d_sql_order is now : %s',d_sql_order)
                            logging.info('current free space for %s is %s',k,v)
                            d_local_free_dev[k] = int(v) - seg_size
                            logging.info('new free space for %s is %s',k,d_local_free_dev[k])
                            dev_found = True
		            break
                    else: # the device is not used yet, let's add it to the right list
                        logging.info('%s is not used yet',k)
                        if seg_type == '3':
                            #add the new device in the list of devices used as data
                            logging.info('add %s in l_dev_data',k)
                            l_dev_data.append(k)
                            logging.info('l_dev_data : %s',l_dev_data)
                        else:
                            #add the new device in the list of devices used as log
                            logging.info('add %s in l_dev_log',k)
                            l_dev_log.append(k)
                            logging.info('l_dev_log : %s',l_dev_log)
                        logging.info('add %s in l_dev_used',k)
                        l_dev_used.append(k)
                        logging.info('l_dev_used : %s',l_dev_used)
                        logging.info('adding %s to d_sql_order',k)
                        d_sql_order[len(d_sql_order)] = k+'='+str(seg_size)
                        logging.info('d_sql_order is now : %s',d_sql_order)
                        logging.info('current free space for %s is %s',k,v)
                        d_local_free_dev[k] = int(v) - seg_size
                        logging.info('new free space for %s is %s',k,d_local_free_dev[k])
                        dev_found = True 
                        break
            if not dev_found: # cannot find a device matching the request
                logging.info('cannot find a device matching the request')
                no_space = True
    if no_space:
        print "\nERROR --- Dataserver does not contain enough free space to load the database\n"
        sys.exit(-2)
    else:
        s = ''
        for key in sorted(d_sql_order.iterkeys()):
          s += d_sql_order[key] + ' , '
        s = s[:-2]
        final_sql = 'CREATE DATABASE ' + s_target_base + ' on ' + s + ' FOR LOAD'
        print "SQL ORDER TO CREATE THE DATABASE : \n"
        print final_sql


# -- THE END --
# -------------
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
