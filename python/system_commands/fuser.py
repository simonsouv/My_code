import os.path, re, shlex, subprocess, sys, time

def erreur(err_msg):
   print 'ERROR: %s' % (err_msg)
   sys.exit(1)

   
def get_process_creation_date(procid):
    p1 = subprocess.Popen(shlex.split(r"""stat -c%Y /proc/""" + procid +\
         '/environ'), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return p1.communicate()[0].split()[0]

    
def get_process_command(procid):
    p1 = subprocess.Popen(shlex.split(r"""cat /proc/""" + procid +\
         '/comm'), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return p1.communicate()[0].split()[0]


def get_process_cmdline_info(procid, prog):
    p1 = subprocess.Popen(shlex.split(r"""cat /proc/""" + procid +\
         '/cmdline'), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    cmdline = p1.communicate()[0].split()[0].replace('\0',' ')

    if prog == 'java':
        re_get_info = re.compile(r""" (?P<is_zk>zookeeper\.log\.dir) |
                                   MXJ_CLASS_NAME:(?:\w+\.){5,6}(?P<class>\w+)
                                  (?:.*?(CONFIG_FILE:(?:\w+\.){3}(?P<cnf>.*?\.mxres)))?
                                  (?:.*?(MXJ_PROCESS_NICK_NAME:(?P<nick>\w+)))?
                                  (?:.*?(MXJ_SERVICE_CODE:(?P<svc>\w+)))?
                                  """, re.VERBOSE)
        match_get_info = re_get_info.search(cmdline)
        if match_get_info.group('is_zk'):
            return 'zookeeper'
        else:
            if match_get_info.group('class') == 'service' or match_get_info.group('class') == 'ServiceServer':
                return match_get_info.group('class') + ' ' +\
                       match_get_info.group('nick') + ' ' +\
                       match_get_info.group('svc')
            else:
                cnf = match_get_info.group('cnf') or ''
                return match_get_info.group('class') + ' ' + cnf

    else: # especially mx binary
        re_get_info = re.compile(r"""MXJ_PROCESS_NICK_NAME:(?P<nick>\w+).*?
                                     MXJ_SERVICE_CODE:(?P<svc>\w+)""", re.VERBOSE)
        match_get_info = re_get_info.search(cmdline)
        if match_get_info:
            return match_get_info.group('nick') + ' ' + match_get_info.group('svc')
        else:
            return ''


def print_tree(input, key, lvl,p_info):
    print '%-15s%-30s%-10s%s' % ('-'*lvl + key, \
          time.strftime("%a, %d %b %Y %H:%M:%S",time.localtime(float(p_info[key][0]))),\
          p_info[key][1], p_info[key][2])
    if key in input:
        for p in input[key]:
            print_tree(input, str(p), lvl+1, p_info)


#
# MAIN
#
if len(sys.argv) < 2:
    erreur("Missing argument")

if not os.path.isdir(sys.argv[1]):
    erreur(sys.argv[1]+" is not a directory")

pid_tree = {}

proc = subprocess.Popen(['fuser',sys.argv[1]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
pid_info = dict((k,list()) for k in proc.communicate()[0].split())
#print pid_list

for pid in pid_info.keys():
    #get pid parent process id
    p1 = subprocess.Popen(shlex.split(r"""awk '{print $4}' /proc/""" + pid +\
        '/stat'), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    ppid = p1.communicate()[0].split()[-1]
    if not ppid in pid_tree:
        pid_tree[ppid] = list()
    if not ppid in pid_info:
        pid_info[ppid] = list()
    pid_tree[ppid].append(pid)
    
    # get pid and ppid creation date
    pid_info[pid].append(get_process_creation_date(pid))
    pid_info[ppid].append(get_process_creation_date(ppid))
    
    # get pid and ppid command
    pid_info[pid].append(get_process_command(pid))
    pid_info[ppid].append(get_process_command(ppid))
    
    # get pid and ppid cmdline info
    pid_info[pid].append(get_process_cmdline_info(pid, pid_info[pid][1]))
    pid_info[ppid].append(get_process_cmdline_info(ppid,pid_info[ppid][1]))

print_tree(pid_tree,'1',0,pid_info)
