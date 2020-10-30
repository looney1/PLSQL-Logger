/* Formatted on 8/17/2015 4:57:28 PM (QP5 v5.277) */

-- Needs privileges to BUS_ORG_LINEAGE_VW to be granted from the BUS_ORG module before the view will create successfully.

DECLARE
   e_view_does_not_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_view_does_not_exist, -942);
BEGIN
   EXECUTE IMMEDIATE 'DROP VIEW module_config_vw';

   DBMS_OUTPUT.put_line ('View module_config_vw Dropped.');
EXCEPTION
   WHEN e_view_does_not_exist THEN
     DBMS_OUTPUT.put_line ('View does not exist.'); 
   WHEN OTHERS THEN
      RAISE;
END;
/


CREATE OR REPLACE FORCE VIEW module_config_vw AS
   WITH latest_settings AS
           (SELECT bus_org_guid, policy_type, VALUE
              FROM (SELECT bus_org_guid,
                           date_eff,
                           policy_type,
                           VALUE,
                           inherit_parent_flag,
                           MAX (date_eff) OVER (PARTITION BY bus_org_guid, policy_type) AS latest_date
                      FROM module_config mc
                     WHERE date_eff <= SYS_EXTRACT_UTC (SYSTIMESTAMP))
             WHERE date_eff = latest_date AND inherit_parent_flag <> 'Y')
     SELECT b.ancestor_bus_org_guid,
            b.descendant_bus_org_guid,
            b.DEPTH,
            ls.policy_type,
            ls.VALUE
       FROM busorg.bus_org_lineage_vw b, latest_settings ls
      WHERE b.ancestor_bus_org_guid = ls.bus_org_guid
   ORDER BY DEPTH
/
