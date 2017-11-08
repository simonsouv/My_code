#list of modules to import
import os
import sys
import glob
import re

def usage(errorID):
    """
    function handling error message
    """
    if errorID == 0:
        print("Missing argument")
    elif errorID == 1:
        print("Path provided doesn't exist")
    elif errorID == 2:
        print("No mxtiming file in Path")
    elif errorID == 3:
        print("Several mxtiming files found in Path")
    print("Script usage: script.py <rootDir>")
    print("rootDir contains log files to analyze")
    sys.exit()

def search_pattern(s_dict_key,re_pattern, s_input, d_res):
    """
    Function that will search a requested pattern and save some metrics
    in the result dictionary
    :param s_dict_key: the key value for the dict storing the results
    :param re_pattern: regexp defining the pattern we're looking for
    :param s_input: string containing the text to parse
    :param d_res: dictionary storing the results
    :return: none
    """
    # particular case where we addition must be done for deal evaluation metrics
    if s_dict_key == 'Deal Evaluation':
        d_res[s_dict_key] = {}
        d_res[s_dict_key]['elapse'] = float(0)
        d_res[s_dict_key]['cpu'] = float(0)
        d_res[s_dict_key]['rdb_com'] = float(0)
        for i in re_pattern.finditer(s_input):
            if re.search('Finish',i.group("ctx")):
                #print(i.group("time"),i.group("oth").split('|')[0].strip()[:-1])
                d_res[s_dict_key]['end_d'] = i.group("date")
                d_res[s_dict_key]['end_t'] = i.group("time")
                d_res[s_dict_key]['elapse'] += float(i.group("oth").\
                                                     split('|')[0].strip()[:-1])
                d_res[s_dict_key]['cpu'] += float(i.group("oth").\
                                                  split('|')[1].strip()[:-1])
                d_res[s_dict_key]['rdb_com'] = float(i.group("oth").\
                                                     split('|')[3].strip()[:-1])
    else:
        for i in re_pattern.finditer(s_input):
            if re.search('Begin',i.group("ctx")) and not re.search(' Process ',i.group("ctx")):
                d_res[s_dict_key] = {}
                d_res[s_dict_key]['start_d'] = i.group("date")
                d_res[s_dict_key]['start_t'] = i.group("time")
                d_res[s_dict_key]['user'] = i.group("user")
                d_res[s_dict_key]['cmd'] = i.group("cmd")
            elif re.search('Finish', i.group("ctx")) and not re.search(' Process ',i.group("ctx")):
                d_res[s_dict_key]['end_d'] = i.group("date")
                d_res[s_dict_key]['end_t'] = i.group("time")
                d_res[s_dict_key]['elapse'] = float(i.group("oth").split('|')[0].strip()[:-1])
                d_res[s_dict_key]['cpu'] = float(i.group("oth").split('|')[1].strip()[:-1])
                d_res[s_dict_key]['cpu_pct'] = i.group("oth").split('|')[2].strip()[:-1]
                d_res[s_dict_key]['rdb_com'] = float(i.group("oth").split('|')[3].strip()[:-1])
                d_res[s_dict_key]['rdb_com_pct'] = i.group("oth").split('|')[4].strip()[:-1]
                d_res[s_dict_key]['mem'] = i.group("oth").split('|')[-1].strip()[:-1]


def analyze_mxtiming(logf):
    """
    function parsing mxtiming log file and extract metrics
    input: full path to mxtiming file
    """
    print(logf)
    timing_summary = {}
    # regex to catch ptf label
    re_target_ptf = re.compile(r'^[0-9]+.*\|Loaded portfolio\s+\|(?P<ptf>.*)\|'
                               ,re.MULTILINE)
    # Define a generic pattern that will be used to search for specific pattern
    s_pattern_begin = '^(?P<date>\d{8}) \s* \| ' + \
                      '(?P<time>\d{2}:\d{2}:\d{2}\.\d{3}) \s* \| ' + \
                      '(?P<user>\w+) \s*\| ' + \
                      '\s* (?P<op_id>\w+) \s* \| ' + \
                      '(?P<ctx>'
    s_pattern_end = '\s*\w*) .*? \| ' + \
                    '\s* (?P<cmd>.*?) \s *\| ' + \
                    '(?P<oth>.*)'
    # regex the number of deals to evaluate
    re_nbe_deals = re.compile(r"""^[0-9]+.*\|
                                 Int\ Deals\ Evaluate\ Begin\s+\|
                                  Deals=(?P<nb_deals>\d+)
                               """, re.MULTILINE| re.VERBOSE)
    #regex to catch the particular case of beginning of Deal Evaluation
    re_deal_eval = re.compile(r"""
                               ^(?P<date>\d{8}) \s* \|
                               (?P<time>\d{2}:\d{2}:\d{2}\.\d{3}) \s* \|
                               (?P<user>\w+) \s*\|
                               \s* (?P<op_id>\w+) \s* \|
                               (?P<ctx>Deal\ Evaluation\ Begin)
                               """, re.MULTILINE | re.VERBOSE)
    with open(logf,'r') as input_f:
        # read the whole file in input
        input = input_f.read()
        # get ptf label
        target_ptf = re_target_ptf.search(input).group("ptf").strip()
        # loop to search a list of pattern
        for i in ['Portfolio Load', 'Int Deals Evaluate', 'Cash Evaluate', \
                  'Convert & Split', 'Post Treatment', 'Deal Evaluation', \
                  'Producers']:
            s_full_pattern = s_pattern_begin + \
                             re.escape(i) + \
                             s_pattern_end
            re_full_pattern = re.compile(s_full_pattern, \
                                         re.MULTILINE | re.VERBOSE)
            search_pattern(i, re_full_pattern, input, timing_summary)
        # get number of deals to be evaluated
        target_nb_deals = re_nbe_deals.search(input).group("nb_deals")
        # get the starting time for deal evaluation metrics
        m_deal_eval = re_deal_eval.search(input)
        #print(m_deal_eval)
        timing_summary['Deal Evaluation']['start_d'] = m_deal_eval.group('date')
        timing_summary['Deal Evaluation']['start_t'] = m_deal_eval.group('time')
        timing_summary['Deal Evaluation']['user'] = m_deal_eval.group('user')
        # append ptf name in the metrics containing the ptf load
        timing_summary['Portfolio Load']['cmd'] += ' (' + target_ptf +')'
        timing_summary['Deal Evaluation']['cmd'] = target_nb_deals + ' deals'

    #for k in sorted(timing_summary.keys()):
        #print(k, timing_summary[k])
    print("{0:50s}{1:20s}{2:20s}{3:20s}{4:20s}{5:>20s}{6:>20s}{7:>20s}".\
          format('Command','Start date','Start time','End_date','End_time',\
                 'Elapsed(s)', 'Elapsed CPU(s)', 'Elapsed RDB+COM(s)'))
    print("{0:50s}{0:20s}{0:20s}{0:20s}{0:20s}{0:>20s}{0:>20s}{0:>20s}".
          format("-" * 5))
    for k in ['Portfolio Load', 'Int Deals Evaluate']:
        print("{0:50s}{1:20s}{2:20s}{3:20s}{4:20s}{5:20.3f}{6:20.3f}{7:20.3f}". \
              format(k + ' ' + timing_summary[k]['cmd'], \
                     timing_summary[k]['start_d'], \
                     timing_summary[k]['start_t'], \
                     timing_summary[k]['end_d'], \
                     timing_summary[k]['end_t'], \
                     timing_summary[k]['elapse'], \
                     timing_summary[k]['cpu'], \
                     timing_summary[k]['rdb_com']))
    for k in ['Deal Evaluation', 'Cash Evaluate','Convert & Split', \
              'Producers', 'Post Treatment']:
        print("{0:50s}{1:20s}{2:20s}{3:20s}{4:20s}{5:20.3f}{6:20.3f}{7:20.3f}".\
              format('    ' + k + ' ' + timing_summary[k]['cmd'], \
                     timing_summary[k]['start_d'], \
                     timing_summary[k]['start_t'], \
                     timing_summary[k]['end_d'],\
                     timing_summary[k]['end_t'], \
                     timing_summary[k]['elapse'], \
                     timing_summary[k]['cpu'], \
                     timing_summary[k]['rdb_com']))

def analyze_viewer_timing(mx_logf,vw_logf):
    """
    :param mx_logf: mxtiming log file used to get the Viewer Operation ID \
                    to search in logger log file
    :param vw: viewer log file to ananlyze
    :return: none
    """
    # First part is to get the block of strings between Pattern
    # 'Post Treatment Begin' and 'Post Treatment Finish'
    re_filter_pattern = re.compile(r'^\d+.*Post Treatment Begin',re.MULTILINE)
    re_vw_id = re.compile(r'Viewer Operation \(Id = (?P<v_id>\d+)\)',re.MULTILINE)
    #re_vw_pattern =  re.compile(r"""
    #                             ^(?P<start_d>\d{8});
    #                             (?P<start_t>\d\d:\d\d:\d\d\.\d{3});
    #                             (?P<end_d>\d{8});
    #                             (?P<end_t>\d\d:\d\d:\d\d\.\d{3});
    #                             (?P<msg_id>\d+);
    #                             (?P<ctx>(|.+?));
    #                             (?P<action>(|.+?));
    #                             (?P<vw>(|.+?));
    #                             (?P<feed>(|.+?));
    #                             (?P<elapse>\d+(|\.\d+));
    #                             (?P<cpu>-?\d+(|\.\d+));
    #                             (?P<mem>-?\d+);
    #                             """, re.MULTILINE | re.VERBOSE)
    with open(mx_logf, 'r') as input_f:
        # read the whole file in input
        input = input_f.read()
        # isolate the part of input containing the view ID to analyze
        # in variable input_viewer_only
        start_position = re_filter_pattern.search(input).start()
        re_filter_pattern = re.compile(r'^\d+.*Post Treatment Finish.*', re.MULTILINE)
        end_position = re_filter_pattern.search(input).end()
    input_viewer_only = input[start_position:end_position]
    # define regex to search viewer information
    vw_pattern_beg = '^(?P<start_d>\d{8});(?P<start_t>\d\d:\d\d:\d\d\.\d{3});'+\
                     '(?P<end_d>\d{8});(?P<end_t>\d\d:\d\d:\d\d\.\d{3});'
    vw_pattern_end = ';(?P<ctx>(|.+?));(?P<action>(|.+?));(?P<vw>(|.+?));' + \
                     '(?P<feed>(|.+?));(?P<elapse>\d+(|\.\d+));' + \
                     '(?P<cpu>-?\d+(|\.\d+));(?P<mem>-?\d+);'

    with open(vw_logf, 'r') as input_f:
        input = input_f.read()
        #print(input)
        vw_timing = {}
        for i in re_vw_id.findall(input_viewer_only):
            #print(i)
            vw_timing[i] = float(0)
            #print(vw_pattern_beg + i + vw_pattern_end)
            re_vw_pattern = re.compile (vw_pattern_beg + i + vw_pattern_end, \
                                        re.MULTILINE)
            #print(re_vw_pattern.search(input))
            for res in re_vw_pattern.finditer(input):
                #print(res['vw'])
                vw_timing[i] += float(res['elapse'])
    print ('\nView operation details\n-----')
    print ('{0:10s}{1:>20s}'.format('View ID','Elapsed (s)'))
    [print('{0:10s}{1:20.3f}'.format(i, vw_timing[i])) for i in vw_timing]


# MAIN
def main():
    """
    main program
    """
    try:
        rootDir = sys.argv[1]
    except IndexError:
        usage(0)
    # check if directory exists
    if not os.path.isdir(rootDir):
        usage(1)
    # check mxtiming file exists
    f_mxtiming = glob.glob(rootDir+"/mxtiming_[0-9][0-9]*.log")
    f_viewer = glob.glob(rootDir+"/viewer_timings_[0-9][0-9]*.csv")
    if len(f_mxtiming) == 0:
        usage(2)
    elif len(f_mxtiming) > 1:
        usage(3)
    analyze_mxtiming(f_mxtiming[0])
    analyze_viewer_timing(f_mxtiming[0], f_viewer[0])

if __name__ =="__main__":
    main()