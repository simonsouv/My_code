# Script parsing a .trc file
# count for ech database connexion
#  -number of queries
#  -total exec time in ms
BEGIN{
}

/^ServerName/{
  currDB = $6;
  #print currDB;
}

/^Murex execution time/{
  #print currDB;
  #print $0;
  time=$4;
  time_ms =$5;
  gsub(":"," ",time);
  time_h = substr(time,1,2) * 3600 * 1000;
  time_m = substr(time,4,2) * 60 * 1000;
  time_s = substr(time,7,2) * 1000;
  total = time_h + time_m + time_s + time_ms;
  #print time_h, time_m, time_s, time_ms, total;
  db_count[currDB] += 1;
  db_time[currDB] += total;
}

END{
  printf "%-20s%-10s\n","Database","Queries #"
  for (key in db_time)
    printf "%-20s%-10s\n", key, db_count[key]
  printf "\n%-20s%-10s\n","Database","total exec time(ms)"
  for (key in db_count)
    printf "%-20s%-10s\n", key, db_time[key]
}