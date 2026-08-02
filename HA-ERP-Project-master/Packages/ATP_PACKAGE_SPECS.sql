-- SELECT object_name, object_type, status 
-- FROM user_objects 
-- WHERE status = 'INVALID';

SET SERVEROUTPUT ON;
DECLARE
    l_role_check VARCHAR2(10);
BEGIN
    -- Test if supplier_auth_pkg is working
    l_role_check := supplier_auth_pkg.has_role('REQUESTER', 'REVIEWER');
    DBMS_OUTPUT.PUT_LINE('Package Test Result: ' || l_role_check);
END;
/

set define off
whenever sqlerror exit sql.sqlcode

create or replace package supplier_auth_pkg as
  function has_role(
    p_actor_roles in varchar2,
    p_required_role in varchar2
  ) return varchar2;

  procedure require_role(
    p_actor_roles in varchar2,
    p_required_role in varchar2
  );

  procedure assert_request_access(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number
  );
end supplier_auth_pkg;
/
  
/
create or replace package supplier_config_pkg as
  function get_number_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in number
  ) return number;

  function get_text_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in varchar2
  ) return varchar2;

  function risk_rule_weight(
    p_rule_code in varchar2
  ) return number;

  function risk_component_total(
    p_component in varchar2
  ) return number;

  function is_high_risk_country(
    p_country_code in varchar2
  ) return varchar2;

  function is_tax_required(
    p_country_code in varchar2,
    p_supplier_type in varchar2 default null
  ) return varchar2;

  procedure validate_risk_allocation;

  procedure update_risk_rule(
    p_actor_subject_id in varchar2,
    p_rule_code in varchar2,
    p_weight in number,
    p_active in varchar2 default 'Y'
  );

  procedure set_high_risk_country(
    p_actor_subject_id in varchar2,
    p_country_code in varchar2,
    p_active in varchar2,
    p_reason in varchar2 default null,
    p_source in varchar2 default null
  );
end supplier_config_pkg;
/

/
create or replace package supplier_dashboard_pkg as
  procedure open_requests(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_result out sys_refcursor
  );

  procedure open_integration_logs(
    p_actor_roles in varchar2,
    p_result out sys_refcursor
  );
end supplier_dashboard_pkg;
/

/
create or replace package supplier_integration_pkg as
  procedure create_job(
    p_request_id in number,
    p_integration_type in varchar2,
    p_payload_reference in varchar2,
    p_job_id out number
  );

  procedure retry_job(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_job_id in number,
    p_new_job_id out number
  );

  procedure retry_latest_failed_request_job(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_new_job_id out number
  );

  procedure claim_job(
    p_job_id in number,
    p_oic_instance_id in varchar2,
    p_correlation_id in varchar2 default null
  );

  procedure complete_job(
    p_job_id in number,
    p_status in varchar2,
    p_response_reference in varchar2 default null,
    p_error_type in varchar2 default null,
    p_error_message in varchar2 default null,
    p_retryable in varchar2 default 'N',
    p_fusion_supplier_id in varchar2 default null,
    p_fusion_supplier_number in varchar2 default null,
    p_ai_summary in varchar2 default null,
    p_ai_recommended_actions in varchar2 default null,
    p_justification_quality in varchar2 default 'UNKNOWN',
    p_model_name in varchar2 default null
  );
end supplier_integration_pkg;
/

/
create or replace package supplier_projection_pkg as
  function normalize_text(p_value in varchar2) return varchar2;
  function fingerprint(p_value in varchar2) return varchar2;
  function mask_identifier(p_value in varchar2) return varchar2;
  function risk_level(p_score in number) return varchar2;

  function allowed_actions(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number
  ) return varchar2;
end supplier_projection_pkg;
/

/
create or replace package supplier_request_pkg as
  procedure create_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_requester_display_name in varchar2,
    p_requester_email in varchar2,
    p_supplier_name in varchar2,
    p_supplier_type in varchar2,
    p_country_code in varchar2,
    p_address_line1 in varchar2,
    p_address_line2 in varchar2 default null,
    p_city in varchar2 default null,
    p_state_or_province in varchar2 default null,
    p_postal_code in varchar2 default null,
    p_contact_person in varchar2 default null,
    p_contact_email in varchar2 default null,
    p_contact_phone in varchar2 default null,
    p_business_unit in varchar2 default null,
    p_business_justification in clob default null,
    p_product_service_category in varchar2 default null,
    p_expected_annual_spend in number default null,
    p_currency_code in varchar2 default 'USD',
    p_tax_registration_number in varchar2 default null,
    p_bank_country_code in varchar2 default null,
    p_bank_currency_code in varchar2 default null,
    p_bank_account_raw in varchar2 default null,
    p_site_name in varchar2 default null,
    p_site_address_line1 in varchar2 default null,
    p_site_city in varchar2 default null,
    p_site_country_code in varchar2 default null,
    p_request_id out number
  );

  procedure update_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_supplier_name in varchar2 default null,
    p_supplier_type in varchar2 default null,
    p_country_code in varchar2 default null,
    p_address_line1 in varchar2 default null,
    p_address_line2 in varchar2 default null,
    p_city in varchar2 default null,
    p_state_or_province in varchar2 default null,
    p_postal_code in varchar2 default null,
    p_contact_person in varchar2 default null,
    p_contact_email in varchar2 default null,
    p_contact_phone in varchar2 default null,
    p_business_unit in varchar2 default null,
    p_business_justification in clob default null,
    p_product_service_category in varchar2 default null,
    p_expected_annual_spend in number default null,
    p_currency_code in varchar2 default null,
    p_tax_registration_number in varchar2 default null,
    p_bank_country_code in varchar2 default null,
    p_bank_currency_code in varchar2 default null,
    p_bank_account_raw in varchar2 default null,
    p_site_name in varchar2 default null,
    p_site_address_line1 in varchar2 default null,
    p_site_city in varchar2 default null,
    p_site_country_code in varchar2 default null
  );

  procedure submit_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_status out varchar2
  );

  procedure add_document(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_document_type in varchar2,
    p_file_name in varchar2,
    p_mime_type in varchar2 default null,
    p_document_content in blob default null,
    p_document_id out number
  );
end supplier_request_pkg;
/

/
create or replace package supplier_review_pkg as
  procedure decide_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_decision in varchar2,
    p_reason in varchar2 default null,
    p_existing_supplier_id in varchar2 default null
  );

  procedure apply_justification_risk_adjustment(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_points in number,
    p_reason in varchar2 default null
  );
end supplier_review_pkg;
/

/
create or replace package supplier_validation_pkg as
  procedure assess_request(
    p_request_id in number,
    p_actor_subject_id in varchar2,
    p_assessment_id out number
  );
end supplier_validation_pkg;
/

/
create or replace package supplier_workflow_pkg as
  function can_transition(
    p_from_status in varchar2,
    p_to_status in varchar2
  ) return varchar2;

  procedure transition_request(
    p_request_id in number,
    p_to_status in varchar2,
    p_action in varchar2,
    p_actor_subject_id in varchar2,
    p_reason in varchar2 default null,
    p_existing_supplier_id in varchar2 default null
  );

  procedure write_action(
    p_request_id in number,
    p_action in varchar2,
    p_from_status in varchar2,
    p_to_status in varchar2,
    p_actor_subject_id in varchar2,
    p_reason in varchar2 default null,
    p_existing_supplier_id in varchar2 default null
  );
end supplier_workflow_pkg;
/

/
