#########################
# Variable initialisation
#########################
BEGIN{
#define a array containing the mapping between month in abbreviation and value
mois_annee["Jan"]=1;mois_annee["Feb"]=2;mois_annee["Mar"]=3;mois_annee["Apr"]=4;mois_annee["May"]=5;mois_annee["Jun"]=6;
mois_annee["Jul"]=7;mois_annee["Aug"]=8;mois_annee["Sep"]=9;mois_annee["Oct"]=10;mois_annee["Nov"]=11;mois_annee["Mar"]=12
}

#############
#Main program
#############

#get date
$0~/^Sampling Ended at/ {
   heure=$NF
   annee=$(NF-1)
   jour=$(NF-2);
   # remove the comma contained in variable jour
   sub(/,/,"",jour)
   mois=mois_annee[$(NF-3)]
}

#get dataserver name
$0~/^Server Name/ {dataserver=$NF}

#get sybase version
$0 ~ /^Server Version/ {chaine=$5;sep="/";split(chaine,array,sep);syb_version=array[2];}

#get kernel metrics
$0~/Kernel Utilization$/{
	##print  "start kernel utilization section"
	if (syb_version ~ /^15./){
		##print  "sybase", syb_version;
		getline;
		while ($1 !="Pool"){getline;} #loop to skip the details of the cpu usage per engine, we go to the average line information
		##print  $0
		getline;
		moyenne_user= $(NF-7); moyenne_system=$(NF-5); moyenne_io=$(NF-3); moyenne_idle=$(NF-1);
		##printf("%s/%s/%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_cpu,moyenne_io,moyenne_idle);
	}
	##print  "end section kernel utilization";
}
#get statistics about cpu the yields of cpu
$0~/Task Context Switches Due To:$/{
	#print  "start task context switches section";
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		getline
		while ($0!~/==========/){		#loop through the block of causes of context switch and get only the relevant one
			context_switch=($1 " " $2 " " $3)	#context_switch contain the identifier of the context switch, the first two identifies uniquely the context switch
			switch (context_switch){	# we get the value only for the context switch below into context_value
				case "Cache Search Misses": context_value=(context_value ";" $(NF-1));break;
				case "Exceeding I/O batch": context_value=(context_value ";" $(NF-1));break;
				case "System Disk Writes": context_value=(context_value ";" $(NF-1));break;
				case "Last Log Page": context_value=(context_value ";" $(NF-1));break;
				case "I/O Device Contention": context_value=(context_value ";" $(NF-1));break;
				case "Network Packet Received": context_value=(context_value ";" $(NF-1));break;
				case "Network Packet Sent": context_value=(context_value ";" $(NF-1));break;
			}
		getline;
		}
		sub(/;/,"",context_value)	#remove the first character in context_value as if it's a ;
		##printf"%s/%s/%s;%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_cpu,moyenne_io,moyenne_idle,context_value;
	}
	##print  "end task context switches section";
}

#get statistics about housekeeper activity
$0~/Housekeeper Task Activity$/{
	#print  "start housekeeper activity section"
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		getline
		while ($1 != "Dirty"){getline;}	#skip the lines up to the line starting with dirty
		#print  $0
		if ($NF=="%") housekeeper_dirty=$(NF-1); else housekeeper_dirty="n/a";
		#printf"%s/%s/%s;%s;%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_cpu,moyenne_io,moyenne_idle,context_value,housekeeper_dirty;
	}
	#print  "end housekeeper activity section"
}

#get statistics about transaction management
$0~/Transaction Management$/{
	#print  "start transaction management section"
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		getline
		while ($0 !~ /Fully Logged DMLs/){getline;} # skip the lines to go to Fully log part
		getline;
		if ($NF=="%") full_ulc=$(NF-1); else full_ulc="n/a"
		getline
		while ($0 !~ /Minimally Logged DMLs/){getline;} # skip the lines to go to Minimally logged log part
		getline;
		if ($NF=="%") minimally_full_ulc=$(NF-1); else minimally_full_ulc="n/a"
		while ($0 !~ /ULC Semaphore Requests/){getline;} # skip the lines to go to ULC semaphore requests section
		getline;getline;
		if ($NF=="%") ulc_sem_wait=$(NF-1); else ulc_sem_wait="n/a"
		getline
		while ($0 !~ /Log Semaphore Requests/){;getline;}	# skip the lines to go the minimally logged section
		getline;getline;
		if ($NF=="%") sem_wait=$(NF-1); else sem_wait"n/a"
		#printf"%s/%s/%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_cpu,moyenne_io,moyenne_idle,context_value,housekeeper_dirty,full_ulc,ulc_sem_wait,sem_wait;
	}
	#print  "end transaction management section"
}

#get statistics about cache management
$0~/Data Cache Management$/{
	#print  "start data cache management section"
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		getline
		while ($0 !~ /Cache Search Summary/){getline;}	#go to cache summary for all caches 
		getline
		if ($NF=="%") all_cache_hit=$(NF-1);else all_cache_hit="n/a" ##print  all_cache_hit
		getline
		if ($NF=="%") all_cache_miss=$(NF-1);##print  all_cache_miss
		getline
		while ($0 !~ /Buffers Grabbed Dirty/){getline;}	#go to section Buffers Grabbed Dirty
		if ($NF=="%") all_cache_buff_grab_dirty=$(NF-1); else all_cache_buff_grab_dirty="n/a"
		getline
		while ($0 !~ /Large I\/Os Denied due to/){getline;}	#go to section Large I/Os Denied due to
		getline;
		if ($NF=="%") large_pool_denied_prefetch=$(NF-1); else large_pool_denied_prefetch="n/a"
		getline
		while ($0 !~ /Large I\/O Effectiveness/){getline;}	#go to section Large I/O Effectiveness
		getline;getline
		if ($NF=="%") large_io_effectiveness=$(NF-1); else large_io_effectiveness="n/a"
		getline
		while ($0 !~/Cache: default data cache/){getline;} #go to default data cache section
		getline
		while ($0 !~/Cache Hits/){getline;}	#go to the default data cache cache hits
		if ($NF=="%") def_cache_hit=$(NF-1); else def_cache_hit="n/a"	##print  def_cache_hit
		getline
		if ($NF=="%") def_cache_hit_wash=$(NF-1);else def_cache_hit_wash="n/a"	##print  def_cache_hit_wash
		getline
		if ($NF=="%") def_cache_miss=$(NF-1);else def_cache_miss="n/a"	##print  def_cache_miss
		getline
		while ($0 !~ /Large I\/Os Denied due to/){getline;}	#go to section Large I/Os Denied due to
		getline;
		if ($NF=="%") def_cache_large_pool_denied_prefetch=$(NF-1); else def_cache_large_pool_denied_prefetch="n/a"
		getline
		while ($0 !~ /Large I\/O Detail/){getline;}	#go to section Large I/O Effectiveness
		getline;getline;getline
		if ($NF=="%") def_cache_large_io_used=$(NF-1); else def_cache_large_io_used="n/a"
		#printf"%s/%s/%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_cpu,moyenne_io,moyenne_idle,context_value,housekeeper_dirty,full_ulc,ulc_sem_wait,sem_wait,all_cache_hit,all_cache_miss,all_cache_buff_grab_dirty,large_pool_denied_prefetch,large_io_effectiveness,def_cache_hit,def_cache_hit_wash,def_cache_miss,def_cache_large_pool_denied_prefetch,def_cache_large_io_used;

	}
	#print  "end data cache management section"
}

#get statistics about  Statement cache
$0~/SQL Statement Cache:$/{
	#print  "start statement cache section"
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		getline
		if ( $NF =="%") stmt_cached=$(NF-1);else stmt_cached="n/a";
		getline
		if ( $NF =="%") stmt_found=$(NF-1);else stmt_found="n/a";
		getline
		if ( $NF =="%") stmt_not_found=$(NF-1);else stmt_not_found="n/a";
		getline
		if ( $NF =="%") stmt_dropped=$(NF-1);else stmt_dropped="n/a";
		#printf"%s/%s/%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_cpu,moyenne_io,moyenne_idle,context_value,housekeeper_dirty,full_ulc,ulc_sem_wait,sem_wait,all_cache_hit,all_cache_miss,all_cache_buff_grab_dirty,large_pool_denied_prefetch,large_io_effectiveness,def_cache_hit,def_cache_hit_wash,def_cache_miss,def_cache_large_pool_denied_prefetch,def_cache_large_io_used,stmt_cached,stmt_found,stmt_not_found,stmt_dropped;
	}
	#print  "end statement cache section"
}

#get statistics about Disk IO Management
$0~/Disk I\/O Management$/{
	#print  "start disk io management section"
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		getline
		while ($0 !~ /Max Outstanding I\/Os/){getline;}	# skip line to go directly to section Max Outstanding I/Os
		max_io=0;
		getline;getline #go to first line
		while ( ($1=="Server") || ($1=="Engine") ) {tmpio=$(NF-1); if (tmpio>max_io){max_io=tmpio;};getline}
		#printf("maxio value is %s\n",max_io)
		getline
		while ($0 !~ /I\/Os Delayed by/){getline;}	# skip line to go directly to section I/Os Delayed by
		getline
		if ($NF=="%") io_struct=$(NF-1); else io_struct="n/a"	##print  IO Structures
		getline
		if ($NF=="%") io_serv_conf_limit=$(NF-1); else io_serv_conf_limit="n/a"	##print  server config limit
		getline
		if ($NF=="%") io_engine_conf_limit=$(NF-1); else io_engine_conf_limit="n/a"	##print  engine config limit
		getline
		if ($NF=="%") io_os_conf_limit=$(NF-1); else io_os_conf_limit="n/a"	##print  operating system config limit
		#printf  "%s/%s/%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_user,moyenne_system,moyenne_io,moyenne_idle,context_value,housekeeper_dirty,full_ulc,minimally_full_ulc,ulc_sem_wait,sem_wait,all_cache_hit,all_cache_miss,all_cache_buff_grab_dirty,large_pool_denied_prefetch,large_io_effectiveness,def_cache_hit,def_cache_hit_wash,def_cache_miss,def_cache_large_pool_denied_prefetch,def_cache_large_io_used,stmt_cached,stmt_found,stmt_not_found,stmt_dropped,max_io,io_struct,io_serv_conf_limit,io_engine_conf_limit,io_os_conf_limit;
	}
	#print "end disk io management section"
}

#get statistics about Network IO Management
$0~/Network I\/O Management$/{
	#print  "start network io management section"
	if (syb_version ~ /^15./){
		#print  "sybase", syb_version;
		while ($0 !~ /Network I\/Os Delayed/){getline;}	# skip line to go directly to section Network I/Os Delayed
		if ($NF=="%") net_delayed=$(NF-1); else inet_delayed="n/a"	##print  server config limit
		getline
		while ($0 !~ /Avg Bytes Rec/){getline;}	# skip line to go directly to section Avg Bytes Rec'd per Packet
		packet_rec_avg_size = $NF
		getline
		while ($0 !~ /Avg Bytes Sent/){getline;}	# skip line to go directly to section Avg Bytes Sent per Packet
		packet_sent_avg_size = $NF
		getline
		printf  "%s/%s/%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n",annee,mois,jour,heure,dataserver,syb_version,moyenne_user,moyenne_system,moyenne_io,moyenne_idle,context_value,housekeeper_dirty,full_ulc,minimally_full_ulc,ulc_sem_wait,sem_wait,all_cache_hit,all_cache_miss,all_cache_buff_grab_dirty,large_pool_denied_prefetch,large_io_effectiveness,def_cache_hit,def_cache_hit_wash,def_cache_miss,def_cache_large_pool_denied_prefetch,def_cache_large_io_used,stmt_cached,stmt_found,stmt_not_found,stmt_dropped,max_io,io_struct,io_serv_conf_limit,io_engine_conf_limit,io_os_conf_limit,net_delayed,packet_rec_avg_size,packet_sent_avg_size;
	}
	#print  "end network io management section"
}
END{
#print  "LA FIN";

}