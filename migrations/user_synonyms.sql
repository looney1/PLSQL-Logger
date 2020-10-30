DECLARE
BEGIN
   EXECUTE IMMEDIATE 'CREATE OR REPLACE SYNONYM ' || USER || '_USER.transaction_log FOR ' || USER || '.transaction_log';
END;
/
DECLARE
BEGIN
   EXECUTE IMMEDIATE 'CREATE OR REPLACE SYNONYM ' || USER || '_USER.client_branding FOR ' || USER || '.client_branding';
END;
/
DECLARE
BEGIN
   EXECUTE IMMEDIATE 'CREATE OR REPLACE SYNONYM ' || USER || '_USER.custom_help FOR ' || USER || '.custom_help';
END;
/
DECLARE
BEGIN
   EXECUTE IMMEDIATE 'CREATE OR REPLACE SYNONYM ' || USER || '_USER.client_branding_vw FOR ' || USER || '.client_branding_vw';
END;
/

