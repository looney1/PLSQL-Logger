/* Formatted on 8/24/2017 5:17:33 PM (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY module_config_dil_pkg AS
    /******************************************************************************
       NAME:       module_config_dil_pkg
       PURPOSE:

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        6/19/2015      jlooney       Created this package.
       1.1        7/13/2015      jlooney       Fixed problem when inserting the same policy_type with the same value creating a new row.
       1.2        8/04/2015      jlooney       Changed DATE_EFF,DATE_END pattern to DATE_EFF as a TIMESTAMP pattern.
       1.3        8/24/2017      jlooney       Updated to meet SonarQube's Standards

    ******************************************************************************/



    g_source          CONSTANT VARCHAR2 (30) := 'MODULE_CONFIG_DIL_PKG';
    g_txn_guid                 transaction_log.txn_guid%TYPE;
    g_request_timestamp        transaction_log.request_timestamp%TYPE;

    e_txn_log_already_exists   EXCEPTION;

    --    e_bad_params               EXCEPTION;


    --------------------------------------------------------------------------------
    PROCEDURE create_txn_log (pi_session_guid        IN transaction_log.session_guid%TYPE,
                              pi_request_guid        IN transaction_log.request_guid%TYPE,
                              pi_txn_guid            IN transaction_log.txn_guid%TYPE,
                              pi_request_timestamp   IN transaction_log.request_timestamp%TYPE,
                              pi_bus_org_guid        IN transaction_log.bus_org_guid%TYPE,
                              pi_entity_name         IN transaction_log.entity_name%TYPE,
                              pi_entity_guid_1       IN transaction_log.entity_guid_1%TYPE,
                              pi_entity_guid_2       IN transaction_log.entity_guid_2%TYPE DEFAULT NULL,
                              pi_login_person_guid   IN transaction_log.login_person_guid%TYPE DEFAULT NULL,
                              pi_proxy_person_guid   IN transaction_log.proxy_person_guid%TYPE DEFAULT NULL,
                              pi_workflow_guid       IN transaction_log.workflow_guid%TYPE DEFAULT NULL,
                              pi_request_method      IN transaction_log.request_method%TYPE DEFAULT NULL,
                              pi_request_uri         IN transaction_log.request_uri%TYPE DEFAULT NULL,
                              pi_message_text        IN transaction_log.MESSAGE_TEXT%TYPE DEFAULT NULL) IS
        v_source   VARCHAR2 (61) := g_source || '.CREATE_TXN_LOG';
    BEGIN
        logger_pkg.set_source (v_source);
        logger_pkg.set_code_location ('INSERT INTO TRANSACTION_LOG');

        INSERT INTO transaction_log (txn_guid,
                                     txn_date,
                                     session_guid,
                                     request_guid,
                                     request_timestamp,
                                     processed_timestamp,
                                     bus_org_guid,
                                     entity_name,
                                     entity_guid_1,
                                     entity_guid_2,
                                     login_person_guid,
                                     proxy_person_guid,
                                     workflow_guid,
                                     request_method,
                                     request_uri,
                                     MESSAGE_TEXT)
             VALUES (pi_txn_guid,
                     pi_request_timestamp,
                     pi_session_guid,
                     pi_request_guid,
                     pi_request_timestamp,
                     SYS_EXTRACT_UTC (SYSTIMESTAMP),
                     pi_bus_org_guid,
                     pi_entity_name,
                     pi_entity_guid_1,
                     pi_entity_guid_2,
                     pi_login_person_guid,
                     pi_proxy_person_guid,
                     pi_workflow_guid,
                     pi_request_method,
                     pi_request_uri,
                     pi_message_text);

        logger_pkg.unset_source (v_source);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            logger_pkg.info (
                   'Transaction Already Processed!  SESSION_GUID='
                || pi_session_guid
                || ' REQUEST_GUID='
                || pi_request_guid
                || ' TRANSACTION_GUID='
                || pi_txn_guid);
            logger_pkg.unset_source (v_source);
            RAISE e_txn_log_already_exists;
        WHEN OTHERS THEN
            logger_pkg.fatal ('ROLLBACK', SQLCODE, SQLERRM);
            logger_pkg.unset_source (v_source);
            RAISE;
    END create_txn_log;

    --------------------------------------------------------------------------------
    PROCEDURE set_txn_context (pi_session_guid        IN transaction_log.session_guid%TYPE,
                               pi_request_guid        IN transaction_log.request_guid%TYPE,
                               pi_txn_guid            IN transaction_log.txn_guid%TYPE,
                               pi_request_timestamp   IN transaction_log.request_timestamp%TYPE,
                               pi_bus_org_guid        IN transaction_log.bus_org_guid%TYPE,
                               pi_entity_name         IN transaction_log.entity_name%TYPE,
                               pi_entity_guid_1       IN transaction_log.entity_guid_1%TYPE,
                               pi_entity_guid_2       IN transaction_log.entity_guid_2%TYPE DEFAULT NULL,
                               pi_login_person_guid   IN transaction_log.login_person_guid%TYPE DEFAULT NULL,
                               pi_proxy_person_guid   IN transaction_log.proxy_person_guid%TYPE DEFAULT NULL,
                               pi_workflow_guid       IN transaction_log.workflow_guid%TYPE DEFAULT NULL,
                               pi_request_method      IN transaction_log.request_method%TYPE DEFAULT NULL,
                               pi_request_uri         IN transaction_log.request_uri%TYPE DEFAULT NULL,
                               pi_message_text        IN transaction_log.MESSAGE_TEXT%TYPE DEFAULT NULL) IS
        v_source   VARCHAR2 (61) := g_source || '.SET_TXN_CONTEXT';
    BEGIN
        logger_pkg.set_source (v_source);

        g_txn_guid            := pi_txn_guid;
        g_request_timestamp   := pi_request_timestamp;

        logger_pkg.set_code_location ('CALL CREATE_TXN_LOG');

        create_txn_log (pi_session_guid,
                        pi_request_guid,
                        pi_txn_guid,
                        pi_request_timestamp,
                        pi_bus_org_guid,
                        pi_entity_name,
                        pi_entity_guid_1,
                        pi_entity_guid_2,
                        pi_login_person_guid,
                        pi_proxy_person_guid,
                        pi_workflow_guid,
                        pi_request_method,
                        pi_request_uri,
                        pi_message_text);
        logger_pkg.unset_source (v_source);
    EXCEPTION
        WHEN e_txn_log_already_exists THEN
            logger_pkg.unset_source (v_source);
        WHEN OTHERS THEN
            logger_pkg.fatal ('ROLLBACK', SQLCODE, SQLERRM);
            ROLLBACK;
            logger_pkg.unset_source (v_source);
            RAISE;
    END set_txn_context;

    --------------------------------------------------------------------------------
    PROCEDURE update_policy_history (pi_bus_org_guid          IN module_config.bus_org_guid%TYPE,
                                     pi_policy_type           IN module_config.policy_type%TYPE,
                                     pi_inherit_parent_flag   IN module_config.inherit_parent_flag%TYPE,
                                     pi_value                 IN module_config.VALUE%TYPE) IS
        v_source             VARCHAR2 (61) := g_source || '.UPDATE_POLICY_HISTORY';
        current_policy_row   module_config%ROWTYPE;
    BEGIN
        logger_pkg.set_source (v_source);
        logger_pkg.set_code_location ('GET CURRENT POLICY');

        BEGIN
            SELECT *
              INTO current_policy_row
              FROM module_config mc
             WHERE bus_org_guid = pi_bus_org_guid
               AND policy_type = pi_policy_type
               AND date_eff =
                   (SELECT MAX (date_eff)
                      FROM module_config
                     WHERE bus_org_guid = mc.bus_org_guid
                       AND policy_type = mc.policy_type
                       AND date_eff <= SYS_EXTRACT_UTC (SYSTIMESTAMP));
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN OTHERS THEN
                RAISE;
        END;

        IF NOT ((pi_inherit_parent_flag = current_policy_row.inherit_parent_flag)
            AND (NVL (pi_value, 'NULL') = NVL (current_policy_row.VALUE, 'NULL'))) THEN
            logger_pkg.set_code_location ('INSERT TABLE MODULE_CONFIG');

            INSERT INTO module_config (module_config_guid,
                                       last_txn_guid,
                                       last_txn_date,
                                       bus_org_guid,
                                       date_eff,
                                       policy_type,
                                       inherit_parent_flag,
                                       VALUE)
                 VALUES (SYS_GUID (),
                         g_txn_guid,
                         g_request_timestamp,
                         pi_bus_org_guid,
                         g_request_timestamp,
                         pi_policy_type,
                         pi_inherit_parent_flag,
                         pi_value);
        END IF;

        logger_pkg.unset_source (v_source);
    EXCEPTION
        WHEN OTHERS THEN
            logger_pkg.fatal ('ROLLBACK', SQLCODE, SQLERRM);
            logger_pkg.unset_source (v_source);
            RAISE;
    END update_policy_history;

    --------------------------------------------------------------------------------
    PROCEDURE change_policy (pi_bus_org_guid          IN module_config.bus_org_guid%TYPE,
                             pi_policy_type           IN module_config.policy_type%TYPE,
                             pi_inherit_parent_flag   IN module_config.inherit_parent_flag%TYPE,
                             pi_value                 IN module_config.VALUE%TYPE,
                             pi_session_guid          IN transaction_log.session_guid%TYPE,
                             pi_request_guid          IN transaction_log.request_guid%TYPE,
                             pi_txn_guid              IN transaction_log.txn_guid%TYPE,
                             pi_request_timestamp     IN transaction_log.request_timestamp%TYPE,
                             pi_entity_name           IN transaction_log.entity_name%TYPE,
                             pi_login_person_guid     IN transaction_log.login_person_guid%TYPE DEFAULT NULL,
                             pi_proxy_person_guid     IN transaction_log.proxy_person_guid%TYPE DEFAULT NULL,
                             pi_workflow_guid         IN transaction_log.workflow_guid%TYPE DEFAULT NULL,
                             pi_request_method        IN transaction_log.request_method%TYPE DEFAULT NULL,
                             pi_request_uri           IN transaction_log.request_uri%TYPE DEFAULT NULL,
                             pi_message_text          IN transaction_log.MESSAGE_TEXT%TYPE DEFAULT NULL) IS
        v_source               VARCHAR2 (61) := g_source || '.CHANGE_POLICY';
        v_module_config_guid   module_config.module_config_guid%TYPE;
    BEGIN
        logger_pkg.set_source (v_source);
        logger_pkg.set_code_location ('GET GUID OF CURRENT ROW');

        BEGIN
            SELECT module_config_guid
              INTO v_module_config_guid
              FROM module_config mc
             WHERE bus_org_guid = pi_bus_org_guid
               AND policy_type = pi_policy_type
               AND date_eff =
                   (SELECT MAX (date_eff)
                      FROM module_config
                     WHERE bus_org_guid = mc.bus_org_guid
                       AND policy_type = mc.policy_type
                       AND date_eff <= SYS_EXTRACT_UTC (SYSTIMESTAMP));
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_module_config_guid   := SYS_GUID ();
        END;

        logger_pkg.set_code_location ('CALL SET_TXN_CONTEXT');
        set_txn_context (pi_session_guid,
                         pi_request_guid,
                         pi_txn_guid,
                         pi_request_timestamp,
                         pi_bus_org_guid,
                         pi_entity_name,
                         v_module_config_guid,
                         NULL,
                         pi_login_person_guid,
                         pi_proxy_person_guid,
                         pi_workflow_guid,
                         pi_request_method,
                         pi_request_uri,
                         pi_message_text);

        logger_pkg.set_code_location ('CALL UPDATE_POLICY_HISTORY');
        update_policy_history (pi_bus_org_guid,
                               pi_policy_type,
                               pi_inherit_parent_flag,
                               pi_value);

        logger_pkg.unset_source (v_source);
    EXCEPTION
        WHEN OTHERS THEN
            logger_pkg.fatal ('ROLLBACK', SQLCODE, SQLERRM);
            logger_pkg.unset_source (v_source);
            RAISE;
    END change_policy;

    --------------------------------------------------------------------------------

    FUNCTION get_applicable_config (pi_bus_org_guid   IN module_config.bus_org_guid%TYPE,
                                    pi_policy_type    IN module_config.policy_type%TYPE)
        RETURN module_config.VALUE%TYPE IS
        CURSOR get_cur IS
            SELECT VALUE
              FROM module_config_vw
             WHERE descendant_bus_org_guid = pi_bus_org_guid AND policy_type = pi_policy_type;

        v_value   module_config_vw.VALUE%TYPE;
    BEGIN
        OPEN get_cur;

        FETCH get_cur INTO v_value;

        CLOSE get_cur;

        RETURN v_value;
    END get_applicable_config;
END module_config_dil_pkg;
/