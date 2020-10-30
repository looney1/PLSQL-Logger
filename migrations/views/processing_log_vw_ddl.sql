DECLARE
   e_view_does_not_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_view_does_not_exist, -942);
BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW processing_log_vw';

   DBMS_OUTPUT.put_line ('View processing_log_vw Dropped.');
EXCEPTION
   WHEN e_view_does_not_exist THEN
     DBMS_OUTPUT.put_line ('View does not exist.'); 
   WHEN OTHERS THEN
      RAISE;
END;
/


CREATE OR REPLACE FORCE VIEW processing_log_vw  AS
     SELECT log_guid,
            log_date,
            trace_level,
            instance_name,
            sid,
            serial#,
            username,
            osuser,
            source,
            code_location,
            start_time,
            end_time,
            end_time - start_time elapsed_interval,
              EXTRACT (HOUR FROM (end_time - start_time)) * 3600
           + EXTRACT (MINUTE FROM (end_time - start_time)) * 60
            + ROUND (EXTRACT (SECOND FROM (end_time - start_time)), 1)
               elapsed_sec,
              EXTRACT (HOUR FROM (end_time - start_time)) * 3600000
            + EXTRACT (MINUTE FROM (end_time - start_time)) * 60000
            + ROUND (EXTRACT (SECOND FROM (end_time - start_time)) * 1000, 1)
               elapsed_msec,
            parent_log_guid,
            transaction_result,
            ERROR_CODE,
            MESSAGE,
            message_clob
       FROM processing_log
      WHERE osuser = SYS_CONTEXT ('USERENV', 'OS_USER') AND log_date >= TRUNC (SYSDATE - 1)
   ORDER BY start_time DESC
/
