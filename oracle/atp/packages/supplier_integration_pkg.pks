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
