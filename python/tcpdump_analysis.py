import time, json, logging, os.path, pprint, re, shlex, sys
from subprocess import Popen, PIPE

def get_pid_info(endpoint):
    error_message=["DNS SPOOFING"]
    res={}
    # check if endpoint is made of ip.port
    if len(endpoint.split('.')) == 2:
        # lsof is used to find pid using a port, problem is for a given port
        # it returns info whether the pid use the port to send or receive data
        # therefore we need to filter output with a regexp
        pid_search = '^[a-z]+\s+(?P<pid>\d+)\s+.*:(?P<port>'+\
                     endpoint.split('.')[1]+')->'
        p = re.compile(pid_search)

        # prepare the command "lsof -i :<port number>" to be executed
        cmd_lsof = "ssh autoengine@"+endpoint.split('.')[0] + " \"" + \
                   "/usr/sbin/lsof -i :" + endpoint.split('.')[1] + "\""
        logging.debug("cmd to execute: %s" % cmd_lsof)
        p1 = Popen(shlex.split(cmd_lsof), stdout=PIPE, stderr=PIPE)
        output_lsof = p1.communicate()

        if not any((True for e in error_message if e in output_lsof[1])):
            for l in output_lsof[0].strip().split('\n'):
                m = p.search(l)
                if m:
                    # we have pid associated to an endpoint host.port, let's look
                    # for the command line
                    if not m.group('pid') in res:
                        res[m.group('pid')] = list()
                        # prepare the command "cat /proc/<pid>/cmdline |
                        # tr -s '\0' ' '" to be executed to retrieve pid args
                        cmd_pid_info = "ssh autoengine@"+endpoint.split('.')[0] + \
                                       " \"" + "cat /proc/" + m.group('pid') + \
                                       "/cmdline" + "\""
                        cmd_tr = "tr -s \'\\0\' \' \'"
                        logging.debug("cmd to get pid args: %s" %cmd_pid_info)
                        p1 = Popen(shlex.split(cmd_pid_info), stdout=PIPE, stderr=PIPE)
                        p2 = Popen(shlex.split(cmd_tr), stdin= p1.stdout,stdout=PIPE, stderr=PIPE)
                        output_pid_info= p2.communicate()
                        pid_args = output_pid_info[0].split(" ")[0] + ' ' + output_pid_info[0].split("MXJ_SITE_NAME")[1].strip()
                        logging.debug("pid info: %s" % pid_args)
                        res[m.group('pid')].append(pid_args)
        else:
            logging.error("Error detected: %s" % output_lsof[1])
    return res

if __name__ == "__main__":
    #logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)
    logging.basicConfig(format='%(message)s', level=logging.INFO)

    if len(sys.argv)<2:
        logging.error("Missing argument")
        sys.exit()

    if not os.path.isfile(sys.argv[1]):
        logging.error("Input file %s does not exist" % sys.argv[1])
        sys.exit(5)

    # result stored in dict net_stats containing 3 disctinct dict
    # one for TCP metrics, one for UDP metrics and one for ICMP metrics
    # each layer4 dict contains a dict of list defined as
    #  key = ip and port if any
    #  value = [a, b, c, d] with
    #    a= TX #packets
    #    b= TX total size
    #    d= RX #packets
    #    b= RX total size
    net_stats = {'TCP':{}, 'UDP':{}, 'ICMP':{}}
    #net_stats['TCP'] = {}
    #net_stats['UDP'] = {}
    #net_stats['ICMP'] = {}

    # endpoint_pid is a dict mapping network endpoint with process id
    endpoint_pid = {}

    # header_output is a dict used at the end to parse net_stats dict
    # and display top 5 metrics through nested loops in order to not
    # repeat several loops by changing parameters
    header_output={0:'TX #packets',\
                   1:'TX total (bytes)',\
                   2:'RX #packets',\
                   3:'RX total (bytes)'}

    p_info = re.compile(r"""^\d{2}.*? \s proto \s
                           (?P<prot>.*?) \s \(.*length \s+
                           (?P<size>\d+)\) \s+
                           (?P<src>.*?) \s > \s
                           (?P<dst>.*?):""", re.VERBOSE)

    # input file contain timestamp in epoch format that we translate
    ts = float(sys.argv[1].split('.')[0].split('_')[-1])

    with open(sys.argv[1],'r') as f:
        l = f.readline().rstrip()
        while l:
            #logging.debug("Current line %s" % l)
            m_info = p_info.search(l)

            if m_info:
                #logging.debug("pattern found.prot: %s, src: %s, dst: %s, size: %s\n", m_info.group("prot"),m_info.group("src"), m_info.group("dst"), m_info.group("size"))
                # init net_stats entry with empty list if key does not exist
                if not m_info.group("src") in net_stats[m_info.group("prot")]:
                    net_stats[m_info.group("prot")][m_info.group("src")]=[0,0,0,0]
                if not m_info.group("dst") in net_stats[m_info.group("prot")]:
                    net_stats[m_info.group("prot")][m_info.group("dst")]=[0,0,0,0]

                # increase number of packet sent
                net_stats[m_info.group("prot")][m_info.group("src")][0] +=1
                # increase number of packet received
                net_stats[m_info.group("prot")][m_info.group("dst")][2] +=1
                # increase total bytes sent
                net_stats[m_info.group("prot")][m_info.group("src")][1] += int(m_info.group("size"))
                # increase total bytes received
                net_stats[m_info.group("prot")][m_info.group("dst")][3] += int(m_info.group("size"))

            else:
                logging.error("Problem parsing line %s", l)
            l = f.readline().rstrip()

    logging.info("=== METRICS FROM TCPDUMP TAKEN ON %s ===" % time.strftime("%a, %d %b %Y %H:%M:%S %Z", time.localtime(ts)))
    for protocol in net_stats.keys():
        for hk,hv in header_output.items():
            logging.info("TOP 5 %s connection by %s" %(protocol, hv))
            tmp_list=list()
            #convert or dictionary of metrics to list of tuples to be sorted
            for k,v in net_stats[protocol].items():
                tmp_list.append((k,v[hk]))
            logging.info("%-20s %-20s %s" % ("Endpoint", hv, "PIDs"))
            for i in sorted(tmp_list,key=lambda (k,v):v, reverse=True)[0:5]:
                logging.debug("get pid info for endpoint: %s", i[0])
                if not i[0] in endpoint_pid:
                    endpoint_pid[0] = get_pid_info(i[0])
                logging.info("%-20s %-20s %-10s" %(i[0], i[1], endpoint_pid[0]))


    # CODE TO BE CONTINUED IF WE WANT TO GRAPH THE METRICS
    # write the different dictionaries in files to be analyzed later
    #base_fname = sys.argv[1].split(".")[0]
    #print base_fname
    #for k in net_stats:
    #    with open(base_fname+"_"+k+".out","w") as f:
    #        f.write("endpoint;TX #packets;TX size(bytes);RX #packets;RX size(bytes)\n")
    #        for sk in net_stats[k]:
    #            l = sk+";"+";".join(map(str,net_stats[k][sk]))+"\n" # use map to convert int to str
    #            f.write(l)