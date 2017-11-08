HOW TO USE get_system_metrics_package
=====================================

get_system_metrics_package is composed of 4 parts

1. generate metrics with sar command in binary format (done with generate_sar_file.sh script)
2. convert sar binary metrics in text format per metrics type (done with extract_sar_to_csv.sh script)
3. convert sart txt metrics in .csv file (done with sar_output_to_csv.py script -- python 3 required --)
4. graph .csv file (done with jupyter notebook)

Installation
------------

Extract the package in a dedicated directory on all servers to be monitored

Package tree
------------

./
--/inputs/ # folder will contain sar command output in bin format
--/outputs/
----------/_csv/ # folder will contain data from subfolders converted to .csv
----------/cpu/ # folder will contain sar cpu metrics from inputs folder files
----------/memory/ # folder will contain sar memory metrics from inputs folder files
----------/swap/ # folder will contain sar swap metrics from inputs folder files
----------/disk/ # folder will contain sar disk metrics from inputs folder files
----------/network/ # folder will contain sar network metrics from inputs folder files
--extract_sar_to_csv.sh
--generate_sar_file.sh
--sar_output_to_csv.py

Execution
---------

    1.Generate sar output
    ---------------------
    The script default behaviour is to continuously execute sar for 1 hour and take metrics every 20s
    If you want to change this behavior, modify the following lines in the script
    
    # default is to execute sar for 1 hour every 20s
    SAR_INT=20
    SAR_COUNT=$(( 3600/${SAR_INT} ))

    On each server execute script generate_sar_file.sh
    
    2.convert sar binary metrics in text format
    -------------------------------------------
    Once the collecting of metrics is finished (stop script generate_sar_file.sh), execute extract_sar_to_csv.sh
    This will generate files under outputs/ subfolders
    
Murex delivery
--------------
Send the content of inputs/ and outputs/ folders to Murex once point 1 and 2 are done

Conversion to csv to be done by Murex
-------------------------------------
Call python script with the path to the outputs/ folder

example: python sar_output_to_csv.py D:\Perso\My_code\unix\linux\outputs
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153503_cpu.csv
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153503_rq.csv
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153528_cpu.csv
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153528_rq.csv
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153553_cpu.csv
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153553_rq.csv
Output file created: D:\Perso\My_code\unix\linux\outputs\cpu\../_csv/sar_Linux_hp440srv_20170706_153618_cpu.csv