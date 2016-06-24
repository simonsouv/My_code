#!/usr/bin/bash

# this script will get a quick summary of servers provided in a text file
# the information requested are:
#    servername
#    architecture and OS
#    number of cpus
#    number of memory

for server in $(cat server_list.txt); do
    #test server connection with ssh
	if [ $(ssh autoengine@${server} "echo 2>&1" && echo $host OK || echo $host NOK) == 'NOK' ]; then
	    echo "cannot connect to server ${server}"
	else
	     #get OS type
	    os_type = ssh autoengine@${server} "uname -a" | awk '{print $1}'
		if [ ${os_type} == 'SunOS' ]; then
		    os_arch=ssh autoengine@${server} "cat /etc/release" | head -1 | awk '{print $NF}'
			os_ver=ssh autoengine@${server} "cat /etc/release" | head -1 | awk '{print $2, $3, $4}'
			cpu=$(ssh  autoengine@${server} "mpstat | wc -l")
			cpu=$((${cpu}-1))
			mem=$( ssh  autoengine@${server} "/etc/prtconf|grep -i mem" | awk '{print $(NF-1)}')
		else
		
		fi
	fi
	
done