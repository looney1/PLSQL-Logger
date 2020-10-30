
/* Formatted on 6/22/2015 1:21:15 PM (QP5 v5.277) */

BEGIN
   DBMS_OUTPUT.enable (1000000);
   DBMS_OUTPUT.put_line ('Begin module_config_ddl.sql Script.');
END;
/

DECLARE
   e_package_does_not_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_package_does_not_exist, -4043);
BEGIN
   EXECUTE IMMEDIATE 'DROP PACKAGE MODULE_CONFIG_DIL_PKG';

   DBMS_OUTPUT.put_line ('Package MODULE_CONFIG_DIL_PKG Dropped.');
EXCEPTION
   WHEN e_package_does_not_exist THEN
      NULL;
   WHEN OTHERS THEN
      RAISE;
END;
/

DECLARE
   e_package_does_not_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_package_does_not_exist, -4043);
BEGIN
   EXECUTE IMMEDIATE 'DROP PACKAGE BODY MODULE_CONFIG_DIL_PKG';

   DBMS_OUTPUT.put_line ('Package Body MODULE_CONFIG_DIL_PKG Dropped.');
EXCEPTION
   WHEN e_package_does_not_exist THEN
      NULL;
   WHEN OTHERS THEN
      RAISE;
END;
/

DECLARE
   e_table_does_not_exists   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_table_does_not_exists, -942);
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE MODULE_CONFIG CASCADE CONSTRAINTS';

   DBMS_OUTPUT.put_line ('Table MODULE_CONFIG Dropped.');
EXCEPTION
   WHEN e_table_does_not_exists THEN
      NULL;
   WHEN OTHERS THEN
      RAISE;
END;
/

DECLARE
   e_table_does_not_exists   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_table_does_not_exists, -942);
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE POLICY_TYPE CASCADE CONSTRAINTS';

   DBMS_OUTPUT.put_line ('Table POLICY_TYPE Dropped.');
EXCEPTION
   WHEN e_table_does_not_exists THEN
      NULL;
   WHEN OTHERS THEN
      RAISE;
END;
/


-- Create tables section -------------------------------------------------

-- Table module_config

CREATE TABLE module_config (
   module_config_guid    RAW (16) NOT NULL,
   last_txn_guid         RAW (16) NOT NULL,
   last_txn_date         DATE DEFAULT SYS_EXTRACT_UTC (SYSTIMESTAMP) NOT NULL,
   bus_org_guid          RAW (16) NOT NULL,
   date_eff              TIMESTAMP DEFAULT SYS_EXTRACT_UTC (SYSTIMESTAMP) NOT NULL,
   policy_type           VARCHAR2 (50) NOT NULL,
   inherit_parent_flag   CHAR (1) NOT NULL CONSTRAINT module_config_ck01 CHECK (inherit_parent_flag IN ('Y', 'N')),
   VALUE                 VARCHAR2 (100),
   CONSTRAINT module_config_ck02 CHECK
      ( ( (inherit_parent_flag = 'Y' AND VALUE IS NULL) OR (inherit_parent_flag = 'N' AND VALUE IS NOT NULL)))
   )
/

-- Create indexes for table module_config

CREATE INDEX module_config_ni01
   ON module_config (last_txn_guid)
/

CREATE INDEX module_config_ni02
   ON module_config (policy_type)
/

CREATE UNIQUE INDEX module_config_ui01
   ON module_config (bus_org_guid, policy_type, date_eff)
/

-- Add keys for table module_config

ALTER TABLE module_config
   ADD CONSTRAINT module_config_pk PRIMARY KEY (module_config_guid)
/

-- Table and Columns comments section

COMMENT ON TABLE module_config IS 'Rules regarding Business Orgs and their associated configurations'
/
COMMENT ON COLUMN module_config.module_config_guid IS 'Unique Identifier for module_config'
/
COMMENT ON COLUMN module_config.last_txn_guid IS 'That last transaction that modified this row.  This includes audit information.'
/
COMMENT ON COLUMN module_config.last_txn_date IS 'The data the last transaction on this row occurred.'
/
COMMENT ON COLUMN module_config.bus_org_guid IS 'The business organization that this row applies to.'
/
COMMENT ON COLUMN module_config.date_eff IS 'The date when this policy and value became effective'
/
COMMENT ON COLUMN module_config.policy_type IS 'What policy / category does this value apply to.'
/
COMMENT ON COLUMN module_config.inherit_parent_flag IS
   'Flag stating if the value should be ignored and the parent''s value be used instead'
/
COMMENT ON COLUMN module_config.VALUE IS 'The value for this policy for this business organization'
/

-- Table policy_type

CREATE TABLE policy_type (
   policy_type   VARCHAR2 (50) NOT NULL,
   description   VARCHAR2 (200))
/

-- Add keys for table policy_type

ALTER TABLE policy_type
   ADD CONSTRAINT policy_type_pk PRIMARY KEY (policy_type)
/

-- Table and Columns comments section

COMMENT ON TABLE policy_type IS 'This table contains all the different configurable variables around the talent pools.  '
/
COMMENT ON COLUMN policy_type.policy_type IS 'The name for the configurable variable. '
/
COMMENT ON COLUMN policy_type.description IS 'Description giving more meaning to the configurable variable. '
/

ALTER TABLE module_config
   ADD CONSTRAINT module_config_fk01 FOREIGN KEY (last_txn_guid) REFERENCES transaction_log (txn_guid)
/

ALTER TABLE module_config
   ADD CONSTRAINT module_config_fk02 FOREIGN KEY (policy_type) REFERENCES policy_type (policy_type)
/

