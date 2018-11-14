import datetime as dt
import os, re, sys
from pprint import pprint


time_re = re.compile(r'[0-9]{2}:[0-9]{2}:[0-9]{2}')
syscall_re = re.compile(r'^\[pid.*:[0-9]{2} (?P<syscall>\w+)')
input_files = []

# python <python_script.py> <root dir> <time range in mins
directory = sys.argv[1]
time_range = int(sys.argv[2])

# get the list of mx_strace.*.log files
for dirpath, dirnames, files in os.walk(directory):
    for name in files:
        if re.match(r'mx_strace.[0-9]+.log',name):
            input_files.append(os.path.join(dirpath, name))

for inputF in input_files:
    # dictionary storing syscalls statistics
    # key = range of time the syscall is triggered
    # value = a dictionnary of syscalls (key=syscall / value=count)
    res = {}
    syscalls_stats = {}
    print 'Analyzing file', inputF
    with open(inputF, "rb") as f:
        first_line = f.readline()        # Read the first line.
        f.seek(-2, os.SEEK_END)          # Jump to the second last byte.
        while f.read(1) != b"\n":        # Until EOL is found...
            f.seek(-2, os.SEEK_CUR)      # ...jump back the read byte plus one more.
        last_line = f.readline()         # Read last line.

    start_time = dt.datetime.strptime(time_re.search(first_line).group(),'%H:%M:%S')
    end_time = dt.datetime.strptime(time_re.search(last_line).group(),'%H:%M:%S')

    # initiate the dictionary values.
    # key = start time
    # all syscall between start_time and start_time + delta minutes are stored
    # in the key
    current_time = start_time
    while current_time < end_time:
        res[current_time] = {}
        current_time = current_time + dt.timedelta(minutes = time_range)

    with open(inputF, "rb") as f:
        for line in f:
            # check if current line is a syscall triggered by MX process
            if syscall_re.search(line):
                # get the time of the call
                current_time = dt.datetime.strptime(\
                                time_re.search(line).group(),'%H:%M:%S')
                for k in res:
                    if current_time >= k and \
                    current_time < (k + dt.timedelta(minutes = time_range)):
                        current_syscall = syscall_re.search(line).group('syscall')
                        if not current_syscall in res[k]:
                            res[k][current_syscall] = 0
                        res[k][current_syscall] += 1

    for k in res:
        syscalls_stats[k.strftime("%H:%M:%S")] = res[k]

    pprint(syscalls_stats)