from bs4 import BeautifulSoup
import datetime as dt
import pac_utils
from pac_utils.html import Document
from pac_utils.common import Table, Graph, Serie
import re, sys

def erreur(message):
    print "ERROR - %s" %(message)
    print "Usage - python diff_nft_html_report py <1st html report> <2nd html report>"
    exit(1)


def get_summary_info (t):
    """
    function retieving release, buildID and time taken to complete NFT test_input
    keep in mind that each html tag is surounded with a '\n' element
    when retrieving element
    """
    res = {}
    v = unicode(t.contents[3].contents[1].string) + '@' + \
        unicode(t.contents[3].contents[5].string)
    tt = unicode(t.contents[7].contents[5].string)
    res['key'] = ['Version','Time taken']
    res['value'] = [v, tt]
    return res


def get_table_info(t1,cle=False):
    """
    function parsing a table and stores the results in a dictionary
    cle sets whether a row has a column (usually first columm) as key, this key
    is later used for value comparison
    if cle is False, set a default key to '0'
    """
    res = {}
    for l in t1.children:
        if l.name and l.td:
            row = [unicode(c.string) for c in l.children if c.name]
            #print 'row: ',row
            if cle:
                # first value of current row is the key of dictionary
                # remaining values are the values
                res[row[0]] = row[1:]
            else:
                res['0'] = row
            #print 'res ', res
    #print res
    return res


def time_to_secs(s):
    """
    function converting a time in hh:mm:ss in seconds
    """
    return sum(x * int(t) for x, t in zip([3600, 60, 1], s.split(":")))


def secs_to_time(secs):
    """
    function converting seconds in hh:mm:ss
    """
    m, s = divmod (abs(secs), 60)
    h, m = divmod (m, 60)
    neg = '-' if secs<0 else ''
    return neg+str(h)+":"+str(m).zfill(2)+":"+str(s).zfill(2)


def compute_diff(src, tgt):
    is_not_number = re.compile(r'[a-zA-Z]')
    is_date = re.compile('\d{4}-\d\d-\d\d')
    res = {}
    src_keys = set(src.keys())
    tgt_keys = set(tgt.keys())

    #print src
    for k in src_keys & tgt_keys: # parse keys common to both dict
        print 'current key: ', k
        values = []
        print 'items ', src[k], tgt[k]
        print 'zip items ',zip(src[k], tgt[k])
        for i,j in zip(src[k], tgt[k]):
            print 'i: ', i
            print 'j: ', j
            if is_not_number.search(i) or is_date.search(i):
                # value starts with a letter or is a date. add raw value
                print i,'is a date or not a number'
                values.append(i)
            else:
                #  value is a numeric value (int / float) or a timestamp
                if ':' in i: # the value is a time stamp
                    print 'i/j ', i, j
                    print 'diff', secs_to_time(time_to_secs(j) - time_to_secs(i))
                    values.append(secs_to_time(\
                                                 time_to_secs(j) - \
                                                 time_to_secs(i)))
                else: # the value is int or float
                    values.append(round(float(j.split()[0]) - \
                                          float(i.split()[0]), 4))
        res[k] = values
    # case where some keys aren't in both dictionaries
    if src_keys ^ tgt_keys:
        for k in src_keys - tgt_keys: # values in src dict but not in tgt
           # as the diff is tgt - src, the result consists in appending '-'
           # to any metrics
            values = []
            for i in src[k]:
                if is_not_number.search(i) or is_date.search(i):
                    values.append(i)
                else:
                    values.append('-'+str(i))
            res[k] = values
        for k in tgt_keys - src_keys: # values in tgt dict but not in src
            # as the diff is tgt - src, the result is tgt
            res[k] = tgt[k]
    print 'res ', res
    return res

def gen_html_diff_table(values, headers, col_remove=[]):
    """
    funct generating a Table html object
    header is the header of the html table
    values contains the table rows
    col_range_remove contains an optional range of results to be removed
    """
    res_table = Table()
    res_table.add_row(headers, header=True)
    print 'values to htmlized ',values
    if col_remove:
        for k in sorted(values):
            #print k, type(k.encode('utf-8'))
            # create a new list with first value equal to dictionary key
            # if its value is not 0
            tmp = list()
            if k != '0':
                tmp.append(k)
            #print tmp
            print 'values to keep on the left ', values[k][:col_remove[0]]
            print 'values to keep on the right', values[k][col_remove[1]:]
            tmp = tmp + values[k][:col_remove[0]] + values[k][col_remove[1]:]
            #print tmp
            res_table.add_row(tmp)
    else :
        for k in sorted(values):
            #print k, type(k.encode('utf-8'))
            # create a new list with first value equal to dictionary key
            # if its value is not 0
            tmp = list()
            if k != '0':
                tmp.append(k)
            #print tmp, type(tmp)
            tmp += values[k]
            res_table.add_row(tmp)
    return res_table

# MAIN

# dictionary containing infos about header to display and columns to remove
# key : index of the table to work on resulting from find_all
# values : a list containing two elements
#          - 1st elem is a list containing the header of the table to draw
#          - 2nd elem is a tuple with range of column to not display
#               - 1st value is the start of range to exclude (value included)
#               - 2nd value is the end of range to exclude (value excluded)
#            example (2:5) --> remove column 2,3,4
data_dict = { '1' :[["Environment Startup ", # LB summary startup table
                     "MD Warmup Completion",\
                     "Livebook Manager Startup",\
                     "RBPL Calculation Sets Startup",\
                     "Full Revaluation Calculation Sets Startup",\
                     "Non BM Full Revaluation Calculation Sets Startup"],[]],\
              '2' :[["Region", # LB summary startup table per region
                     "PL Storage Completion",\
                     "RBPL Run Startup",\
                     "Full Revaluation LB Startup",\
                     "RBPL LB Startup"],[]],\
              '3' :[['Script name', # MD warmup startup table
                     'delta startup time'],[0,2]],\
              '4' :[['Script name', # PL storage startup table
                     'delta startup time'],[0,2]],\
              '6' :[['Service name', # RBPL init load startup table
                     'delta daily',\
                     'delta stock',\
                     'delta overnight',\
                     'delta total',\
                     'delta Startup time (s)',\
                     'delta DB load & engines start (s)',\
                     'delta WH latency (s)',\
                     'delta Warmup & SOD (s)',\
                     'delta Initial Refresh (s)',\
                     'delta Daily computation (s)'],[4,6]],\
              '7' :[['Nickname', # RBPL GC tables
                     'delta Max Mem After Full GC (MB)',\
                     'delta Max Mem After GC (MB)',\
                     'delta Total Full GC (s)',\
                     'delta Max Full GC Pause (s)',\
                     'delta Total GC (s)',\
                     'delta Max GC Pause (s)',\
                     'delta Max Footprint (MB)'],[0,2]],\
              '10':[['Calculation Set', # Calculation set init load table
                     'Livebook', 'delta MDR Positions',\
                     'delta PU Positions',\
                     ' delta Total Positions',\
                     'delta Startup time(s)',\
                     'delta MDR Actors Instantiation(s)',\
                     'delta MDR Warehouse Notifications(s)',\
                     'delta MDR Positions Buffering(s)',\
                     'delta MDR Positions Loading(s)',\
                     'delta PU Actors Instantiation(s)',\
                     'delta PU Warehouse Notifications(s)',\
                     'delta PU Positions Buffering(s)',\
                     'delta PU Positions Loading(s)',\
                     'delta Max memory taken by MDR engine(Mb)',\
                     'delta Max memory taken by PU engine(Mb)'],[4,6]],\
              '11':[['NickName', # Calculation set gc table
                     'Launcher',\
                     'delta Max Mem After Full GC (MB)',\
                     'delta Max Mem After GC (MB)',\
                     'delta Total Full GC (s)',\
                     'delta Max Full GC Pause (s)',\
                     'delta Total GC (s)',\
                     'delta Max GC Pause (s)',\
                     'delta Max Footprint (MB)'],[1,3]],\
              '12':[['Livebook name', # LB startup time
                     'delta Time taken(s)'],[0,2]],\
              '13':[['Table Name', # MX fin db metrics table
                     'delta Inserts',\
                     'delta Updates',\
                     'delta Deletes'],[]],\
              '14':[['Table Name', # MX dm db metrics table
                     'delta Inserts',\
                     'delta Updates',\
                     'delta Deletes'],[]]
             }

src_tables = list()
tgt_tables = list()

#check the number of provided arguments
if len(sys.argv) < 3:
    erreur('Missing arguments')

try:
    with open(sys.argv[1]) as f:
        src1_html = BeautifulSoup(f,"lxml")
except IOError as e:
        erreur(str(e))

try:
    with open(sys.argv[2]) as f:
        src2_html = BeautifulSoup(f,"lxml")
except IOError as e:
        erreur(str(e))

for t in src1_html.find_all("table"):
    src_tables.append(t.contents[1])

for t in src2_html.find_all("table"):
    tgt_tables.append(t.contents[1])

# get summary table containing version information, global startup time
src_info = get_summary_info(src_tables[0])
tgt_info = get_summary_info(tgt_tables[0])

src_tt_in_s = time_to_secs(src_info['value'][1])
tgt_tt_in_s = time_to_secs(tgt_info['value'][1])

summary_table = Table()
summary_table.add_row(['Source1 version', 'Source1 file', 'Source2 version', \
                       'Source2 file', 'Source1 time taken', \
                       'Source2 time taken', 'delta time taken'], header=True)
summary_table.add_row([src_info['value'][0], sys.argv[1], tgt_info['value'][0], \
                     sys.argv[2], src_info['value'][1], tgt_info['value'][1], \
                     secs_to_time(tgt_tt_in_s - src_tt_in_s)])

# Livebook startup time comparison
src_startup = get_table_info(src_tables[1])
tgt_startup = get_table_info(tgt_tables[1])
diff = compute_diff(src_startup, tgt_startup)
startup_table = gen_html_diff_table(diff,data_dict['1'][0], data_dict['1'][1])

# Region startup time comparison
src_startup = get_table_info(src_tables[2], True)
tgt_startup = get_table_info(tgt_tables[2], True)
diff = compute_diff(src_startup, tgt_startup)
region_table = gen_html_diff_table(diff,data_dict['2'][0], data_dict['2'][1])

# market data warmup startup time comparison
src_startup = get_table_info(src_tables[3], True)
tgt_startup = get_table_info(tgt_tables[3], True)
diff = compute_diff(src_startup, tgt_startup)
md_warmup_table = gen_html_diff_table(diff,data_dict['3'][0], data_dict['3'][1])

# PL Storage startup time comparison
src_startup = get_table_info(src_tables[4], True)
tgt_startup = get_table_info(tgt_tables[4], True)
diff = compute_diff(src_startup, tgt_startup)
pl_warmup_table = gen_html_diff_table(diff,data_dict['4'][0], data_dict['4'][1])

# RBPL startup time comparison
src_startup = get_table_info(src_tables[6], True)
tgt_startup = get_table_info(tgt_tables[6], True)
diff = compute_diff(src_startup, tgt_startup)
rbpl_init_load_table = gen_html_diff_table(diff,data_dict['6'][0], data_dict['6'][1])
# RBPL gc comparison
src_startup = get_table_info(src_tables[7], True)
tgt_startup = get_table_info(tgt_tables[7], True)
diff = compute_diff(src_startup, tgt_startup)
rbpl_gc_table = gen_html_diff_table(diff,data_dict['7'][0], data_dict['7'][1])

# Calculation set init load comparison
src_startup = get_table_info(src_tables[10], True)
tgt_startup = get_table_info(tgt_tables[10], True)
diff = compute_diff(src_startup, tgt_startup)
cset_init_table = gen_html_diff_table(diff,data_dict['10'][0], data_dict['10'][1])
# Calculation set gc comparison
src_startup = get_table_info(src_tables[11], True)
tgt_startup = get_table_info(tgt_tables[11], True)
diff = compute_diff(src_startup, tgt_startup)
cset_gc_table = gen_html_diff_table(diff,data_dict['11'][0], data_dict['11'][1])

# Livebook startup time comparison
src_startup = get_table_info(src_tables[12], True)
tgt_startup = get_table_info(tgt_tables[12], True)
diff = compute_diff(src_startup, tgt_startup)
lb_startup_table = gen_html_diff_table(diff,data_dict['12'][0], data_dict['12'][1])
diff = compute_diff(src_startup, tgt_startup)

# Fin db comparison
src_startup = get_table_info(src_tables[13], True)
tgt_startup = get_table_info(tgt_tables[13], True)
diff = compute_diff(src_startup, tgt_startup)
fin_db_table = gen_html_diff_table(diff,data_dict['13'][0], data_dict['13'][1])

# Datamart db comparison
src_startup = get_table_info(src_tables[14], True)
tgt_startup = get_table_info(tgt_tables[14], True)
diff = compute_diff(src_startup, tgt_startup)
dm_db_table = gen_html_diff_table(diff,data_dict['14'][0], data_dict['14'][1])

# Generate html document
document = Document('results.htm')
document.add_title('Test summary', 2)
document.add_table(summary_table)
document.add_line_break()

document.add_title('Livebook Startup Timeline*', 3)
document.add_table(startup_table)
document.add_line_break()
document.add_table(region_table)
document.add_paragraph('*Time difference is with reference to the fileserver start time')
document.add_line_break()

document.add_title('Market Data Warmup', 2)
document.add_title('Startup Time', 3)
document.add_table(md_warmup_table)
document.add_line_break()

document.add_title('PL Storage', 2)
document.add_title('Startup Time', 3)
document.add_table(pl_warmup_table)
document.add_line_break()

document.add_title('RBPL RUN', 2)
document.add_title('Initial load', 3)
document.add_table(rbpl_init_load_table)
document.add_title('Services', 3)
document.add_table(rbpl_gc_table)
document.add_line_break()

document.add_title('Calculation Set', 2)
document.add_title('Initial load', 3)
document.add_table(cset_init_table)
document.add_title('Services', 3)
document.add_table(cset_gc_table)
document.add_line_break()

document.add_title('Livebook', 2)
document.add_title('Startup Time', 3)
document.add_table(lb_startup_table)
document.add_line_break()

document.add_title('Database tables monitoring', 2)
document.add_title('Financial DB', 3)
document.add_table(fin_db_table)
document.add_title('Reporting DB', 3)
document.add_table(dm_db_table)

document.close()