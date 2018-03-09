SET SERVEROUT ON
 
DECLARE
  -- Define a record type to hold tablespace information
  TYPE tblspc_info_record_type IS RECORD (
    tblspc_name dba_segments.tablespace_name%TYPE, 
    tblspc_size number(6));
 
  -- Define a varray type to hold tablepsaces
  TYPE tblspc_infos_varray_type IS VARRAY(1000) 
    of tblspc_info_record_type;
 
  -- Define a varray type to hold user names
  TYPE usr_names_varray_type IS VARRAY(1000) 
    of dba_users.username%TYPE;
 
  tblspc_infos tblspc_infos_varray_type;
  usr_names usr_names_varray_type;
  tmp_usr_name dba_users.username%TYPE;
  min_size_mb number(6) := 500;
BEGIN
    SELECT username 
    BULK COLLECT INTO usr_names
    FROM dba_users ORDER BY username ASC;
 
    tmp_usr_name := '';
    FOR i IN 1 .. usr_names.count LOOP
      IF tmp_usr_name != usr_names(i) THEN
        DBMS_OUTPUT.PUT(CHR(10));
        DBMS_OUTPUT.PUT_LINE('========= User name: ' 
          || usr_names(i) || '============');
      END IF;
      tmp_usr_name := usr_names(i);
 
      SELECT tablespace_name, Sum(bytes)/1024/1024
      BULK COLLECT INTO tblspc_infos
      FROM dba_segments
      WHERE owner = Upper(usr_names(i))
      GROUP BY tablespace_name
      ORDER BY tablespace_name;
 
      FOR j IN 1 .. tblspc_infos.count LOOP
        IF tblspc_infos(j).tblspc_size > min_size_mb THEN
        DBMS_OUTPUT.PUT_LINE('Consumes tablespace ' 
          || tblspc_infos(j).tblspc_name 
          || ' size: '
          || tblspc_infos(j).tblspc_size || ' MB');
        END IF;
      END LOOP;
    END LOOP;
END;
/