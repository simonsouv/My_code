# awk script that will print some metrics about bulk copy from .trc file
BEGIN{
compteur=0
total=0
bulksize=0
}

$0 ~/Bulk_Copy into BBVA_UAT2_DM..DT_GENERIC_REP/{
  bulksize += $(NF-2)
  getline;getline;getline;getline;
  time=$4;
  time_ms =$5;
  gsub(":"," ",time);
  time_h = substr(time,1,2) * 3600 * 1000;
  time_m = substr(time,4,2) * 60 * 1000;
  time_s = substr(time,7,2) * 1000;
  time_in_ms = time_h + time_m + time_s + time_ms;
  compteur += 1
  total += time_in_ms
  #print time_in_ms
}
END{
  printf "%-9s%-9s%-15s%-15s\n","#bulk","bulk size", "total time(ms)","avg time(ms)"
  printf "%-9d%-9d%-15d%-15d\n",compteur, bulksize/compteur, total, total/compteur
}