import re
import copy
from collections import defaultdict
"""
    python script that parses the output of command
    'top -b -d "xx:yy"' in order to get
    global cpu metrics
    process cpu metrics
    memory metrics
    The list of pid to search is hardcoded in the script

    The script creates 3 .txt file with metrics for
      global cpu metrics
      cpu metrics
      memory metrics
    Those files can feed excel for visual representation
"""
# list of pid we want to get cpu%
mr_engines = sorted(['45314', '45317', '45318', '45342', '45580',
                     '46382', '46384', '46385', '46386', '46388',
                     '46390', '46401', '46402', '46403', '46404',
                     '46405', '46414'])

# generate the regexp to search for pid
mr_regexp = "^("
for i in mr_engines:
    mr_regexp = mr_regexp + i + "|"
mr_regexp = mr_regexp[:-1]
mr_regexp += ")(.*)"
# print(mr_regexp)

# -- FILES USED --
# top input file
top_h = open('D:/Tmp/BBVA/cases/case_684074/logs_MX/simon.top', 'r')
tmp_content = top_h.read()

# tweak input file
# add the end of block marker at the end of the file
tmp_content += "===== END ====="
# replace each '^top -' with end of block marker + '^top -'
tmp_pat = re.compile(r"^top -", re.MULTILINE)
tmp_pat.match(tmp_content)
tmp_content2 = tmp_pat.sub("===== END =====\ntop -",tmp_content)
# remove the first line corresponding to "===== END ====="
top_content = tmp_content2[16:]

# global_cpu output file.
# header of the file is: date %us %sy %ni %id %wa
glob_h = open('d:/top_global_cpu.txt', 'w')
glob_h.write("date;%us;%sy;%ni;%id;%wa\n")  # header of the file

# pid_cpu output file.
# header of the file is: date <list of pids>
cpu_h = open('d:/top_pid_cpu.txt', 'w')
cpu_h.write("date " + ';'.join(mr_engines) + '\n')  # header of the file

# mem output file.
# header of the file is: date mem_free mem_buff swap_free swap_cached
glob_m = open('d:/top_global_mem.txt', 'w')
glob_m.write("date;mem_free;mem_buff;swap_free;swap_cached\n")

# -- SPLIT INPUT FILES IN BLOCKS --
# regexp to get blocks of top output store in list_pattern
pattern = re.compile(r"^top - (.*?)^===== END =====", re.MULTILINE | re.DOTALL)
list_pattern = pattern.findall(top_content)

# regexp to get the date of the top command
pat_date = re.compile(r"^\d{2}:\d{2}:\d{2}")

# -- GET GLOBAL CPU METRICS --
# loop to get global cpu statistics
pat_cpu = re.compile(r"""^Cpu\(s\):(\s+)(?P<us>\d\d?\.\d\d?)%us,
                        (\s+)(?P<sy>\d\d?\.\d\d?)%sy,
                        (\s+)(?P<ni>\d\d?\.\d\d?)%ni,
                        (\s+)(?P<id>\d\d?\.\d\d?)%id,
                        (\s+)(?P<wa>\d\d?\.\d\d?)%wa,
                        (\s+)(?P<hi>\d\d?\.\d\d?)%hi,
                        (\s+)(?P<si>\d\d?\.\d\d?)%si,
                        (\s+)(?P<st>\d\d?\.\d\d?)%st
                      """, re.MULTILINE | re.VERBOSE)
for item in list_pattern:
    curr_line = ''
    # get current date
    curr_date = pat_date.search(item).group()
    # print(curr_date,  type(curr_date))
    # get current cpu statistics
    # curr_cpu = pat_cpu.search(item).group().split()
    match = pat_cpu.search(item)
    # print(match)
    curr_line += curr_date + ';' + match.group("us") + ';'
    curr_line += match.group("sy") + ';' + match.group("ni") + ';'
    curr_line += match.group("id") + ';' + match.group("wa") + '\n'
    glob_h.write(curr_line)
glob_h.close()

# -- GET PID CPU METRICS --
# loop to get overall cpu statistics
pat_npid = re.compile(mr_regexp, re.MULTILINE)
npid_metrics = {}
for item in list_pattern:
    curr_date = pat_date.search(item).group()
    if len(pat_npid.findall(item)):
        # findall returns a list of pid with corresponding metrics found
        # tmp dict that will have key/value pair = pid/cpu%
        tmp_dict = {npid: 0 for npid in mr_engines}
        for k in pat_npid.findall(item):
            # we iter the list to get the cpu% for each pid found
            # print(k[0], k[1].split()[7])
            tmp_dict[k[0]] = k[1].split()[7]
        # print(type(tmp_dict))
        # make a copy of tmp_dict because we clean it just after
        # and it's a non-immutable object
        npid_metrics[curr_date] = copy.deepcopy(tmp_dict)
        # print(npid_metrics[curr_date])
        tmp_dict.clear()
# print(npid_metrics)
curr_l = ''
# iter the pid dictionary to generate the output file
for k in npid_metrics.keys():
    curr_l += k
    v = npid_metrics[k]
    for sk in sorted(v.keys()):
        curr_l = curr_l + ';' + str(v[sk])
    cpu_h.write(curr_l + '\n')
    curr_l = ''
cpu_h.close()

# --GET MEMORY METRICS --
# loop to get overall memory statistics
# pat_mem = re.compile(r"^Mem:(.*)", re.MULTILINE)
pat_mem = re.compile(r"""^Mem:(\s+)(\w+)(\s+)(total,)
                     (\s+)(\w+)(\s+)(used,)
                     (\s+)(?P<free>\w+)(\s+)(free,)
                     (\s+)(?P<buffer>\w+)(\s+)(buffers)?""",
                     re.MULTILINE | re.VERBOSE)
d_mem = {}
for item in list_pattern:
    # get current date
    curr_date = pat_date.search(item).group()
    # print(curr_date,  type(curr_date))
    # get current memory statistics
    match = pat_mem.search(item)
    # from curr_mem we just get the metrics we're interested in.
    curr_line = match.group("free")[:-1] + ';' + match.group("buffer")[:-1]
    d_mem[curr_date] = curr_line
# print(d_mem)
# loop to get overall memory statistics
pat_swp = re.compile(r"""^Swap:(\s+)(\w+)(\s+)(total,)
                     (\s+)(\w+)(\s+)(used,)
                     (\s+)(?P<free>\w+)(\s+)(free,)
                     (\s+)(?P<cached>\w+)(\s+)(cached)?""",
                     re.MULTILINE | re.VERBOSE)
d_swp = {}
for item in list_pattern:
    # get current date
    curr_date = pat_date.search(item).group()
    # print(curr_date,  type(curr_date))
    # get current swpory statistics
    match = pat_swp.search(item)
    # from curr_swp we just get the metrics we're interested in.
    # the format of a metric is <metric>k. We remove the last char
    curr_line = match.group("free")[:-1] + ';' + match.group("cached")[:-1]
    d_swp[curr_date] = curr_line
# print(d_swp)

d_mem_swp = {k: [d_mem[k], d_swp[k]] for k in d_mem}
# print(d_mem_swp)
# iter d_mem_swp to generate output file
for k, v in d_mem_swp.items():
    glob_m.write(k + ';' + ';'.join(v) + '\n')
