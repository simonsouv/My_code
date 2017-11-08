import sys
import os
import re
import copy
from collections import defaultdict

"""
    python script that transform the output
    of sar txt file to ,csv

    .csv can be graphed in Jupyter notebook
"""

def usage(errorID):
    if errorID == 0:
        print("Miss argument")
    print("Script usage: python sar_output_to_csv.py <rootDir>")
    print("rootDir contains cpu/disk/memory/network/swap folders "+\
    "containing sar .out files")
    sys.exit()

def toCsv(f):
    import os.path
    #print('value of f:{}'.format(f))
    # retrieve filename
    fileName = os.path.basename(f)
    #print('value of fileName:{}'.format(fileName))
    outputDir = os.path.join(os.path.dirname(f),'../_csv/')
    #print('value of outputDir:{}'.format(outputDir))
    outputF = outputDir + fileName[:-4] + '.csv'
    fileNameDetails = fileName.split('_')
    os, metricType = fileNameDetails[1], fileNameDetails[-1][:-4]
    # print(fileNameDetails)
    # print("Filename: {}\nOS: {}\nMetric: {}\n".format(fileName, os, metricType))
    inputH = open(f, 'r',encoding = 'ISO-8859-1')
    # print(inputH.readline())
    data = inputH.read()
    # Define the different pattern use for the regex
    cpu_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                              (?P<us>\d\d?)\s+
                              (?P<sys>\d\d?)\s+
                              (?P<wio>\d\d?)\s+
                              (?P<idl>\d\d?)
                          """, re.MULTILINE|re.VERBOSE)

    rq_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                              (?P<runq>\d\d?[.]\d\d?)\s+
                              (?P<runo>\d\d?)\s+
                              (?P<swpq>\d\d?[.]\d\d?)\s+
                              (?P<swpo>\d\d?)
                          """, re.MULTILINE|re.VERBOSE)

    io_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d|)\s+
                             (?P<dev>\w+)\s+
                             (?P<busy>\d+)\s+
                             (?P<avq>\d+[.]\d+)\s+
                             (?P<rw>\d+)\s+
                             (?P<blk>\d+)\s+
                             (?P<avwt>\d+[.]\d+)\s+
                             (?P<avsv>\d+[.]\d+)
                         """, re.MULTILINE|re.VERBOSE)

    mem_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                             (?P<mem>\d+)\s+
                             (?P<swp>\d+)
                         """, re.MULTILINE|re.VERBOSE)

    pg_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                             (?P<pgo>\d+[.]\d\d?)\s+
                             (?P<ppgo>\d+[.]\d\d?)\s+
                             (?P<pgf>\d+[.]\d\d?)\s+
                             (?P<pgs>\d+[.]\d\d?)\s+
                         """, re.MULTILINE|re.VERBOSE)

    sw_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                             (?P<swi>\d+[.]\d\d?)\s+
                             (?P<bwi>\d+[.]\d\d?)\s+
                             (?P<swo>\d+[.]\d\d?)\s+
                             (?P<bwo>\d+[.]\d\d?)\s+
                             (?P<psw>\d+)
                         """, re.MULTILINE|re.VERBOSE)

    # network information only available on linux
    net_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                             (?P<if>\w+)\s+
                             (?P<rxp>\d+[.]\d\d?)\s+
                             (?P<txp>\d+[.]\d\d?)\s+
                             (?P<rxb>\d+[.]\d\d?)\s+
                             (?P<txb>\d+[.]\d\d?)\s+
                             (?P<rxc>\d+[.]\d\d?)\s+
                             (?P<txc>\d+[.]\d\d?)\s+
                             (?P<cst>\d+[.]\d\d?)
                         """, re.MULTILINE|re.VERBOSE)

    # sar output is coming from solaris
    if ( os == 'SunOS' ):
        outputH = open(outputF,'w')
        # get cpu info
        if ( metricType == 'cpu' ):
            outputH.write("time;pct_usr;pct_sys;pct_wio;pct_idle\n")
            [ outputH.write(i.group("time") + ";" + i.group("us") + ";" +\
             i.group("sys") + ";" + i.group("wio") + ";" + i.group("idl") +\
            "\n") for i in cpu_pat.finditer(data) ]
        # get rq info
        elif ( metricType == 'rq' ):
            outputH.write("time;runq-sz;swpq-sz;pct_swpocc\n")
            [outputH.write(i.group("time") + ";" + i.group("runq") + ";" +\
            i.group("runo") + ";" + i.group("swpo") + "\n")\
            for i in rq_pat.finditer(data)]
        # get disk info
        elif ( metricType == 'io' ):
            outputH.write("time;dev;pct_busy;avque;r+w/s;blks/s;avwait;avserv\n")
            ts = ""
            for i in io_pat.finditer(data):
                #print(i.group("time"))
                if i.group("time") :
                    ts = i.group("time")
                outputH.write(ts + ";" + i.group("dev") + ";" + i.group("busy") + ";" +\
                i.group("avq") + ";" + i.group("rw") + ";" + i.group("blk") + ";" +\
                i.group("avwt") + ";" + i.group("avsv") + "\n")
        # get memory info
        elif ( metricType == 'mem' ):
            outputH.write("time;freemem;freeswap\n")
            [outputH.write(i.group("time") + ";" + i.group("mem") + ";" +\
            i.group("swp") + "\n") for i in mem_pat.finditer(data)]
        # get paging info
        elif ( metricType == 'pg' ):
            outputH.write("time;pgout/s;ppgout/s;pgfree/s;pgscan/s\n")
            [outputH.write(i.group("time") + ";" + i.group("pgo") + ";" +\
            i.group("ppgo") + ";" + i.group("pgf") + ";" + i.group("pgf") +\
            "\n") for i in pg_pat.finditer(data)]
        # get swapping info
        elif ( metricType == 'sw' ):
            outputH.write("time;swpin/s;bswin/s;swpot/s;bswot/s;pswch/s\n")
            [outputH.write(i.group("time") + ";" + i.group("swi") + ";" +\
            i.group("bwi") + ";" + i.group("swo") + ";" + i.group("bwo") +\
            ";" + i.group("psw") + "\n") for i in sw_pat.finditer(data)]
        print("Output file created: {}".format(outputF))
        outputH.close()
    # sar output is coming from linux
    else:
        outputH = open(outputF,'w')
        # get cpu info
        if ( metricType == 'cpu' ):
            # Change the regex to match cpu pattern
            cpu_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                      (?P<cpuid>\w{1,3})\s+
                                      (?P<us>\d\d?.\d\d)\s+
                                      (?P<ni>\d\d?.\d\d)\s+
                                      (?P<sys>\d\d?.\d\d)\s+
                                      (?P<wio>\d\d?.\d\d)\s+
                                      (?P<st>\d\d?.\d\d)\s+
                                      (?P<idl>\d\d?.\d\d)\s+
                                    """, re.MULTILINE|re.VERBOSE)
            outputH.write("time;cpuid;pct_usr;pct_sys;pct_wio;pct_idle\n")
            [outputH.write(i.group("time") + ";" + i.group("cpuid") + ";" +\
             i.group("us") + ";" + i.group("sys") + ";" + i.group("wio") +\
             ";" + i.group("idl") + "\n") for i in cpu_pat.finditer(data)]
        # get run queue info
        elif ( metricType == 'rq' ):
            # Change the regex to match run queue pattern
            rq_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                  (?P<runq>\d\d?)\s+
                                  (?P<plist>\d+)\s+
                                  (?P<ld1>\d\d?[.]\d\d?)\s+
                                  (?P<ld5>\d\d?[.]\d\d?)\s+
                                  (?P<ld15>\d\d?[.]\d\d?)
                                 """, re.MULTILINE|re.VERBOSE)
            outputH.write("time;runq-sz;ldavg-1;ldavg-5;ldavg-15\n")
            [outputH.write(i[0] + ";" + i[1] + ";" + i[3] + ";" + i[4] + ";" + i[5] +\
             "\n") for i in rq_pat.findall(data)]
        # get io info
        elif ( metricType == 'io' ):
            # On Linux sar for io provide general info and detailed info
            # therefore we need two output files
            outputDetailedF = re.sub('_io.','_io_detailed.',outputF)
            outputDetailedH = open(outputDetailedF,'w')
            io_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                     (?P<tps>\d+[.]\d\d?)\s+
                                     (?P<rtps>\d+[.]\d\d?)\s+
                                     (?P<wtps>\d+[.]\d\d?)\s+
                                     (?P<br>\d+[.]\d\d?)\s+
                                     (?P<bw>\d+[.]\d\d?)
                         """, re.MULTILINE|re.VERBOSE)
            outputH.write("time;tps;rtps;wtps;bread/s;bwrtn/s\n")
            [outputH.write(i.group("time") + ";" + i.group("tps") + ";" +\
            i.group("rtps") + ";" + i.group("wtps") + ";" + i.group("br") +\
            ";" + i.group("bw") + "\n") for i in io_pat.finditer(data)]
            io_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                     (?P<dev>\w+)\s+
                                     (?P<tps>\d+[.]\d\d?)\s+
                                     (?P<rs>\d+[.]\d\d?)\s+
                                     (?P<ws>\d+[.]\d\d?)\s+
                                     (?P<rqsz>\d+[.]\d\d?)\s+
                                     (?P<qusz>\d+[.]\d\d?)\s+
                                     (?P<await>\d+[.]\d\d?)\s+
                                     (?P<svct>\d+[.]\d\d?)\s+
                                     (?P<util>\d+[.]\d\d?)
                         """, re.MULTILINE|re.VERBOSE)
            outputDetailedH.write("time;dev;tps;r/s;w/s;avgrq-sz;\
            avgqu-sz;await;svctm;pct_util\n")
            [outputDetailedH.write(i.group("time") + ";" + i.group("dev") + ";" +\
            i.group("tps") + ";" + i.group("rs") + ";" + i.group("ws") + ";" +\
            i.group("rqsz") + ";" + i.group("qusz") + ";" + i.group("await") + ";" +\
            i.group("svct") + ";" + i.group("util") + "\n") \
            for i in io_pat.finditer(data)]
            outputDetailedH.close()
        # get mem info
        elif ( metricType == 'mem' ):
            mem_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                      (?P<memf>\d+)\s+
                                      (?P<memu>\d+)\s+
                                      (?P<pct_mem>\d+[.]\d\d?)\s+
                                      (?P<buf>\d+)\s+
                                      (?P<cache>\d+)
                                  """, re.MULTILINE|re.VERBOSE)
            outputH.write("time;kbmemfree;kbmemused;pct_memused;kbbuffers;kbcached\n")
            [outputH.write(i.group("time") + ";" + i.group("memf") + ";" + i.group("memu") +\
            ";" + i.group("pct_mem") + ";" + i.group("buf") + ";" + i.group("cache") +\
            "\n") for i in mem_pat.finditer(data)]
        # get paging info
        elif ( metricType == 'pg' ):
            pg_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                     (?P<pgpi>\d+[.]\d\d?)\s+
                                     (?P<pgpo>\d+[.]\d\d?)\s+
                                     (?P<pgf>\d+[.]\d\d?)\s+
                                     (?P<pgsk>\d+[.]\d\d?)\s+
                                     (?P<pgsd>\d+[.]\d\d?)\s+
                                     (?P<pstl>\d+[.]\d\d?)\s+
                                 """, re.MULTILINE|re.VERBOSE)
            outputH.write("time;pgpgin/s;pgpgout/s;pgfree/s;pgscank/s;pgscand/s;pgsteal/s\n")
            [outputH.write(i.group("time") + ";" + i.group("pgpi") + ";" +\
            i.group("pgpo") + ";" + i.group("pgf") + ";" + i.group("pgsk") +\
            ";" + i.group("pgsd") + ";" + i.group("pstl") + "\n")\
            for i in pg_pat.finditer(data)]
        # get swapping info
        elif ( metricType == 'sw'):
            sw_pat = re.compile(r"""^(?P<time>\d\d:\d\d:\d\d)\s+
                                     (?P<free>\d+)\s+
                                     (?P<used>\d+)\s+
                                     (?P<puse>\d+[.]\d\d?)
                                 """, re.MULTILINE|re.VERBOSE)
            outputH.write("time;kbswpfree;kbswpused;pct_swpused\n")
            [outputH.write(i.group("time") + ";" + i.group("free") + ";" +\
            i.group("used") + ";" + i.group("puse") + "\n") \
            for i in sw_pat.finditer(data)]
        # get network info
        elif ( metricType == 'net'):
            # On Linux sar for network provide general info and detailed info
            # therefore we need two output files
            outputDetailedF = re.sub('_net.','_net_detailed.',outputF)
            outputDetailedH = open(outputDetailedF,'w')
            #get detailed metric
            outputDetailedH.write("time;IFace;rxpck/s;txpck/s;rxkB/s;txkB/s;rxcmp/s;" +\
            "txcmp/s;rxmcst/s\n")
            [outputDetailedH.write(i.group("time") + ";" + i.group("if") + ";" + \
            i.group("rxp") + ";" + i.group("txp") + ";" + i.group("rxb") + ";" +\
            i.group("txb") + ";" + i.group("rxc") + ";" + i.group("txc") + ";" +\
            i.group("cst") + "\n") for i in net_pat.finditer(data)]
            outputDetailedH.close()
            # get avg metric per interface
            net_pat = re.compile(r"""^(?P<time>Average:)\s+
                                      (?P<if>\w+)\s+
                                      (?P<rxp>\d+[.]\d\d?)\s+
                                      (?P<txp>\d+[.]\d\d?)\s+
                                      (?P<rxb>\d+[.]\d\d?)\s+
                                      (?P<txb>\d+[.]\d\d?)\s+
                                      (?P<rxc>\d+[.]\d\d?)\s+
                                      (?P<txc>\d+[.]\d\d?)\s+
                                      (?P<cst>\d+[.]\d\d?)
                                 """, re.MULTILINE|re.VERBOSE)
            outputH.write("IFace;rxpck/s;txpck/s;rxkB/s;txkB/s;rxcmp/s;" +\
            "txcmp/s;rxmcst/s\n")
            [outputH.write(i.group("if") + ";" + i.group("rxp") + ";" +\
            i.group("txp") + ";" + i.group("rxb") + ";" +i.group("txb") + ";" +\
            i.group("rxc") + ";" + i.group("txc") + ";" +i.group("cst") + "\n")\
            for i in net_pat.finditer(data)]
        print("Output file created: {}".format(outputF))
        outputH.close()

def main():
    print(len(sys.argv),sys.argv)
    try:
        rootDir = sys.argv[1]
    except IndexError:
        usage(0)
    for root, dir, files in os.walk(rootDir):
        for currF in files:
            if currF.endswith(".out"):
                toCsv(os.path.join(root,currF))

# MAIN PROGRAM
#
if __name__ =="__main__":
    main()