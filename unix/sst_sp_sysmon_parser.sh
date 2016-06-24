#!/usr/bin/bash
#set -x
# script calling recursively sst_sp_sysmon_parser.awk to analyse all sp_sysmon output file and generat a .csv file for analysis
# Assumption is that sp_sysmon output files are named in a way the sort by name reflect the sort by execution
# Assumption is that sp_sysmon output filename starts with sp_sysmon and with .txt extension

#############################
# Variables definition
#############################
SP_SYSMON_AWK_DIR=/cygdrive/d/Perso/My_code/unix
SP_SYSMON_AWK_FILE=${SP_SYSMON_AWK_DIR}/sst_sp_sysmon_parser.awk
SP_SYSMON_OUTPUT_FILES=/cygdrive/d/Tmp/MEDIOBANCA/PAC_migration_stream/PAC_improvement/ULC_32k_diskIO_5500
RESULT_DIR=/cygdrive/d/Tmp/MEDIOBANCA/PAC_migration_stream/PAC_improvement/ULC_32k_diskIO_5500
RESULT_FILE=${RESULT_DIR}/sp_sysmon_$(date +%Y%m%d_%H%M)_results.csv

#############################
# MAIN
#############################

if [ ! -r ${SP_SYSMON_AWK_FILE} ] ; then
  printf "\n%s is not readble, please check\n" "${SP_SYSMON_AWK_FILE}"
  exit 1
fi

if [ ! -d ${SP_SYSMON_OUTPUT_FILES} ] ; then
  printf "\n%s is not a directory, please check\n" "${SP_SYSMON_OUTPUT_FILES}"
  exit 1
fi

if [ ! -d ${RESULT_DIR} ] ; then
  printf "\n%s is not a directory, please check\n" "${RESULT_DIR}"
  exit 1
fi

touch ${RESULT_FILE}
if [ $? -ne 0 ] ; then
  printf "\ncannot write in %s, please check" "${RESULT_DIR}"
  exit 1
fi

#add header to result file
printf "date;time;dataserver;version;user_percent;system_percent;io_percent;idle_percent;ctx_switch_cache_search_miss;ctx_switch_exceedint_IO;ctx_switch_system_disk;ctx_switch_Last_log_page_write;ctx_switch_IO_device_contention;ctx_switch_network_packet_received;ctx_switch_network_packet_sent;housekeeper_wash_dirty;ulc_flush_by_full_ulc;_minimally_logged_ulc_flush_by_full_ulc;_ulc_log_semaphore_wait;_ulc_semaphore_wait;all_caches_hit;_all_caches_miss;_all_caches_buffer_grabbed_dirty;_all_caches_large_io_denied_pool_too_small;all_caches_large_io_effectiveness;def_data_cache_hit;def_data_cache_hit_in_wash;def_data_cache_miss;def_data_cache_large_io_denied_pool_too_small;def_data_cache_large_io_used;stmt_cached;stmt_found;_stmt_not_found;stmt_dropped;max_outstanding_io;io_delay_structure_io;io_delay_server_config;_io_delay_engine_config;_io_delay_os_config;network_IO_delayed;Avg_bytes_input_per_packet;Avg_bytes_output_per_packet\n" > ${RESULT_FILE}

printf "\nStart parsing sp_sysmon output files saved under %s\n" "${SP_SYSMON_OUTPUT_FILES}"
for i in $(ls ${SP_SYSMON_OUTPUT_FILES}/sp_sysmon*.txt) ; do
  #echo $i
  awk -f ${SP_SYSMON_AWK_FILE} $i >> ${RESULT_FILE}
  #print "\n" >> ${RESULT_FILE}
done

printf "\nParsing done, please check result file %s" "${RESULT_FILE}"
