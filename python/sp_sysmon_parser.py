import re
import copy

#list of pid we want to get cpu%
mr_engines=sorted(['45314','45317','45318','45342','45580','46382','46384','46385','46386','46388','46390','46401','46402','46403','46404','46405','46414'])

#generate the regexp to search for pid defined above
mr_regexp="^("
for i in mr_engines:
    mr_regexp = mr_regexp + i + "|"
mr_regexp = mr_regexp[:-1]
mr_regexp += ")(.*)"

#print(mr_regexp)
#filename = 'D:/Tmp/BBVA/PAC_STREAM/Migration/20170328_FebDB2017_43664Binary/sp_sysmon/sp_sysmon_MX626ZN_170324_121544.txt'
#top input file
top_f='D:/Tmp/BBVA/cases/case_684074/logs_MX/simon.top'
top_h = open(top_f,'r')
top_content = top_h.read()

#global_cpu output file
#input format is: date %us %sy %ni %id %wa
glob_h = open('d:/top_global_cpu.txt','w')
glob_h.write("date %us %sy %ni %id %wa\n")

#pid_cpu output file
#input format is: date %us %sy %ni %id %wa
cpu_h = open('d:/top_pid_cpu.txt','w')
cpu_h.write("date " + ' '.join(mr_engines) +'\n')

#regexp to get block of top output
pattern = re.compile(r"^top - (.*?)^===== END =====", re.MULTILINE|re.DOTALL)
#bingo = pattern.search(file_content)
#print(len(bingo.groups()))
list_pattern = pattern.findall(top_content)

pat_date = re.compile(r"^\d{2}:\d{2}:\d{2}")

#loop to get overall cpu statistics
pat_cpu = re.compile(r"^Cpu(.*)",re.MULTILINE)
for item in list_pattern:
    #get current date
    curr_date = pat_date.search(item).group()
    #print(curr_date, type(curr_date))
    #get current cpu statistics
    curr_cpu = pat_cpu.search(item).group().split()
    curr_line = curr_date,curr_cpu[1][:-4],curr_cpu[2][:-4],curr_cpu[3][:-4],curr_cpu[4][:-4],curr_cpu[5][:-4]
    #print(curr_date,curr_cpu[1][:-4],curr_cpu[2][:-4],curr_cpu[3][:-4],curr_cpu[4][:-4],curr_cpu[5][:-4])
    glob_h.write(' '.join(curr_line))
    glob_h.write('\n')
glob_h.close()

#loop to get overall cpu statistics
pat_npid = re.compile(mr_regexp,re.MULTILINE)
npid_metrics = {}
for item in list_pattern:
    curr_date = pat_date.search(item).group()
    if len(pat_npid.findall(item)):
        #for the current top output, we get a list of metrics for our npid
        tmp_dict = {npid:0 for npid in mr_engines}
        for k in pat_npid.findall(item):
            #we iter the list to get the cpu% for each npid found
            #print(k[0],k[1].split()[7])
            tmp_dict[k[0]] = k[1].split()[7]
        #print(type(tmp_dict))
        #make a copy of tmP_dict because we clean it just after and it's a non-immutable object
        npid_metrics[curr_date] = copy.deepcopy(tmp_dict) 
        #print(npid_metrics[curr_date])
        tmp_dict.clear()
#print(npid_metrics)
curr_l = ''
for k in npid_metrics.keys():
    curr_l += k
    v = npid_metrics[k]
    for sk in sorted(v.keys()):
        curr_l = curr_l + ' ' + str(v[sk])
    cpu_h.write(curr_l)
    cpu_h.write('\n')
    curr_l = ''
cpu_h.close()