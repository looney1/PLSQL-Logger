/* Formatted on 12/16/2015 2:44:05 PM (QP5 v5.277) */
CREATE TABLE transaction_log
(
   txn_guid              RAW (16) NOT NULL,
   txn_date              DATE DEFAULT SYSDATE NOT NULL,
   session_guid          RAW (16) NOT NULL,
   request_guid          RAW (16) NOT NULL,
   request_timestamp     TIMESTAMP (6) NOT NULL,
   processed_timestamp   TIMESTAMP (6) NOT NULL,
   bus_org_guid          RAW (16) NOT NULL,
   entity_name           VARCHAR2 (100) NOT NULL,
   entity_guid_1         RAW (16) NOT NULL,
   entity_guid_2         RAW (16),
   login_person_guid     RAW (16),
   proxy_person_guid     RAW (16),
   workflow_guid         RAW (16),
   request_method        VARCHAR2 (30),
   request_uri           VARCHAR2 (2000),
   MESSAGE_TEXT          CLOB
)
PARTITION BY RANGE
   (txn_date)
   INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') )
   (PARTITION transaction_log_rp201601 VALUES LESS THAN (TO_DATE ('01-01-2016', 'MM-DD-YYYY')))
/

-- Create indexes for table transaction_log

CREATE INDEX transaction_log_ni01
   ON transaction_log (entity_name, entity_guid_1)
/

CREATE INDEX transaction_log_ni02
   ON transaction_log (request_timestamp)
/

-- Add keys for table transaction_log

ALTER TABLE transaction_log
   ADD CONSTRAINT transaction_log_pk PRIMARY KEY (txn_guid)
/

ALTER TABLE transaction_log
   ADD CONSTRAINT transaction_log_ui01 UNIQUE (session_guid, request_guid, txn_guid)
/

-- Table and Columns comments section

COMMENT ON COLUMN transaction_log.txn_guid IS
   'Third part of the Event Triplet - Generated by the Orchestration layer, or the data layer in the case where they are not provided'
/
COMMENT ON COLUMN transaction_log.txn_date IS
   'Date this record was written.  Typically the same as processed_date, but a field of type DATE was needed as a partition key.'
/
COMMENT ON COLUMN transaction_log.session_guid IS
   'First part of the Event Triplet - Generated by the security layer, or the data layer in the case where they are not provided'
/
COMMENT ON COLUMN transaction_log.request_guid IS
   'Second part of the Event Triplet - Generated at the UI layer, or the data layer in the case where they are not provided'
/
COMMENT ON COLUMN transaction_log.request_timestamp IS
   'This is the exact timestamp of when the request was created, or when the button was pressed. '
/
COMMENT ON COLUMN transaction_log.processed_timestamp IS
   'This is the timestamp of when the transaction was persisted in the database.  This should be set to now() or sysdate() by the code that performs the insert.  No triggers.  Ever'
/
COMMENT ON COLUMN transaction_log.bus_org_guid IS 'Bus Org context the request was created in'
/
COMMENT ON COLUMN transaction_log.entity_name IS 'Business Entity Name being modified or created'
/
COMMENT ON COLUMN transaction_log.entity_guid_1 IS 'Business Entity guid being modified or created'
/
COMMENT ON COLUMN transaction_log.entity_guid_2 IS 'If a Business Entity has a two part key, the second part goes here.'
/
COMMENT ON COLUMN transaction_log.login_person_guid IS 'Person guid of the credentials entered to login to they system'
/
COMMENT ON COLUMN transaction_log.proxy_person_guid IS 'Person guid being acted on the behalf of'
/
COMMENT ON COLUMN transaction_log.workflow_guid IS 'If the event was created by a workflow, record this guid'
/
COMMENT ON COLUMN transaction_log.request_method IS 'REST Action (PUT, POST) or Message Queue Action'
/
COMMENT ON COLUMN transaction_log.request_uri IS 'REST URI or Message Queue Name this event was handled by'
/
COMMENT ON COLUMN transaction_log.MESSAGE_TEXT IS 'Actual JSON text of the event'
/
