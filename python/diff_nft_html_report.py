from bs4 import BeautifulSoup
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


def get_table_info(t1):
    """
    function parsing a table and stores the results in a dictionary
    dictionary keys store the header of the table
    dictionary values store the rows of the table
    """
    res = {}
    k = list()
    v = list()
    for l in t1.children:
        if l.name:
            if l.th:
                k = [unicode(c.string) for c in l.children if c.name]
            if l.td:
                v.append([unicode(c.string) for c in l.children \
                          if c.name])
    res['key'] = k
    res ['value'] = v
    return res


def time_to_secs(s):
    """
    function converting a time in hh:mm:ss in seconds
    """
    return sum(x * int(t) for x, t in \
               zip([3600, 60, 1], s.split(":")))


def secs_to_time(secs):
    """
    function converting seconds in hh:mm:ss
    """
    m, s = divmod (abs(secs), 60)
    h, m = divmod (m, 60)
    neg = '-' if secs<0 else ''
    return neg+str(h)+":"+str(m).zfill(2)+":"+str(s).zfill(2)


def compute_diff(list_of_list_src, list_of_list_tgt):
    """
    function computing difference between two lists of list
    those lists must contain only values in format hh:mm:ss
    ls and lt are lists of list
    """
    is_not_number = re.compile(r'[a-zA-Z]')
    is_date = re.compile('\d{4}-\d\d-\d\d')
    res = list()
    # zip ls and lt in order to create an iterator of tuples containing each
    # individual list
    for sub_list_src, sub_list_tgt in zip(list_of_list_src, list_of_list_tgt):
        # zip again the indivual list to get an iterator if tuples containing
        # individual values that are to be compared together
        tmp_list = list()
        for item_src,item_tgt in zip(sub_list_src, sub_list_tgt):
            if is_not_number.search(item_src) or is_date.search(item_src):
                # the value starts with a letter or contains '-'
                # meaning it's a date. We don't process anything
                tmp_list.append(item_src)
            else:
                # the value is whether a numeric value (int / float)
                # or a timestamp
                if ':' in item_tgt:
                    # the value is a time stamp
                    tmp_list.append(secs_to_time(\
                                                 time_to_secs(item_tgt) - \
                                                 time_to_secs(item_src)))
                else:
                    # the value is int or float
                    tmp_list.append(round(float(item_tgt.split()[0]) - \
                                          float(item_src.split()[0]), 4))
        res.append(tmp_list)
    return res


def gen_html_diff_table(src1, src2, list_of_headers, col_range_remove=None):
    """
    funct that will generate a Table html object with the difference of values
    between src1 and src2
    src1 and src2 are the lists of values to compare
    header is the header of the html table
    col_range_remove contains an optional range of results to be removed
    """
    res_table = Table()
    res_table.add_row(list_of_headers, header=True)
    if col_range_remove:
        res = [ i[:col_range_remove[0]] + i[col_range_remove[1]:] for i in \
               compute_diff(src1, src2) ]
    else:
        res = [ i for i in compute_diff(src1, src2) ]
    [ res_table.add_row(i) for i in res ]
    return res_table


# MAIN

#check the number of provided arguments
if len(sys.argv) < 3:
    erreur('Missing arguments')

# try to open first html report file
try:
    with open(sys.argv[1]) as f:
        src1_html = BeautifulSoup(f,"lxml")
except IOError as e:
        erreur(str(e))

# try to open second html report file
try:
    with open(sys.argv[2]) as f:
        src2_html = BeautifulSoup(f,"lxml")
except IOError as e:
        erreur(str(e))

src_tables = list()
tgt_tables = list()

for t in src1_html.find_all("table"): #get all tables in the html
    # t will contain '\n', 'the body part' and '\n', we want only the 2nd elem
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
startup_table = gen_html_diff_table(src_startup['value'], tgt_startup['value'],\
                                    src_startup['key'])

# Region startup time comparison
src_startup = get_table_info(src_tables[2])
tgt_startup = get_table_info(tgt_tables[2])
region_table = gen_html_diff_table(src_startup['value'], tgt_startup['value'],\
                                   src_startup['key'])

# market data warmup startup time comparison
src_startup = get_table_info(src_tables[3])
tgt_startup = get_table_info(tgt_tables[3])
h = ['Script name','delta startup time']
md_warmup_table = gen_html_diff_table(src_startup['value'], \
                                      tgt_startup['value'], h, [1,3])

# PL Storage startup time comparison
src_startup = get_table_info(src_tables[4])
tgt_startup = get_table_info(tgt_tables[4])
h = ['Script name','delta startup time']
pl_warmup_table = gen_html_diff_table(src_startup['value'],\
                                      tgt_startup['value'],h, [1,3])

# RBPL startup time comparison
src_startup = get_table_info(src_tables[6])
tgt_startup = get_table_info(tgt_tables[6])
h = ['Service name','delta daily', 'delta stock', 'delta overnight', \
     'delta total', 'delta Startup time (s)', \
     'delta DB load & engines start (s)', 'delta WH latency (s)', \
     'delta Warmup & SOD (s)', 'delta Initial Refresh (s)', \
     'delta Daily computation (s)']
rbpl_init_load_table = gen_html_diff_table(src_startup['value'], \
                                           tgt_startup['value'],h,[5,7])

# RBPL gc comparison
src_startup = get_table_info(src_tables[7])
tgt_startup = get_table_info(tgt_tables[7])
h = ['Nickname', 'delta Max Mem After Full GC (MB)', \
     'delta Max Mem After GC (MB)', 'delta Total Full GC (s)', \
     'delta Max Full GC Pause (s)', 'delta Total GC (s)', \
     'delta Max GC Pause (s)', 'delta Max Footprint (MB)']
rbpl_gc_table = gen_html_diff_table(src_startup['value'], tgt_startup['value'],\
                                    h, [1,3])

# Calculation set init load comparison
src_startup = get_table_info(src_tables[10])
tgt_startup = get_table_info(tgt_tables[10])
h = ['Calculation Set', 'Livebook', 'delta MDR Positions', \
     'delta PU Positions', ' delta Total Positions','delta Startup time(s)', \
     'delta MDR Actors Instantiation(s)', \
     'delta MDR Warehouse Notifications(s)', 'delta MDR Positions Buffering(s)',\
     'delta MDR Positions Loading(s)', 'delta PU Actors Instantiation(s)', \
     'delta PU Warehouse Notifications(s)','delta PU Positions Buffering(s)', \
     'delta PU Positions Loading(s)', 'delta Max memory taken by MDR engine(Mb)',\
     'delta Max memory taken by PU engine(Mb)']
cset_init_table = gen_html_diff_table(src_startup['value'], \
                                      tgt_startup['value'], h, [5, 7])

# Calculation set gc comparison
src_startup = get_table_info(src_tables[11])
tgt_startup = get_table_info(tgt_tables[11])
h = ['NickName', 'Launcher', 'delta Max Mem After Full GC (MB)', \
     'delta Max Mem After GC (MB)', 'delta Total Full GC (s)', \
     'delta Max Full GC Pause (s)', 'delta Total GC (s)', 'delta Max GC Pause (s)',
     'delta Max Footprint (MB)']
cset_gc_table = gen_html_diff_table(src_startup['value'], tgt_startup['value'], \
                                    h, [2, 4])

# Livebook startup time comparison
src_startup = get_table_info(src_tables[12])
tgt_startup = get_table_info(tgt_tables[12])
h = ['Livebook name', 'delta Time taken(s)']
lb_startup_table = gen_html_diff_table(src_startup['value'], \
                                       tgt_startup['value'], h, [1,3])

# Fin db comparison
src_startup = get_table_info(src_tables[13])
tgt_startup = get_table_info(tgt_tables[13])
h = ['Table Name', 'delta Inserts', 'delta Updates', 'delta Deletes']
fin_db_table = gen_html_diff_table(src_startup['value'], tgt_startup['value'], h)

# Datamart db comparison
src_startup = get_table_info(src_tables[14])
tgt_startup = get_table_info(tgt_tables[14])
h = ['Table Name', 'delta Inserts', 'delta Updates', 'delta Deletes']
dm_db_table = gen_html_diff_table(src_startup['value'], tgt_startup['value'], h)

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