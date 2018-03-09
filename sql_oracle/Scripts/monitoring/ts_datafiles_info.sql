--
-- Script that provide information about datafiles used by tablespace
-- and the sum
BREAK ON tablespace_name SKIP 2;
COMPUTE SUM OF allocated_bytes, free_bytes ON tablespace_name;
COLUMN allocated_bytes FORMAT 999,999,999,999
COLUMN free_bytes FORMAT 999,999,999,999
 
SELECT a.tablespace_name, a.file_name, a.bytes allocated_bytes, b.free_bytes
FROM dba_data_files a,
 (SELECT file_id, SUM(bytes) free_bytes
  FROM dba_free_space b GROUP BY file_id) b
WHERE a.file_id=b.file_id
ORDER BY a.tablespace_name;