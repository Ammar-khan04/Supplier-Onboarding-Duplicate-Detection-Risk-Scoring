create or replace package body supplier_integration_pkg as
  procedure create_job(
    p_request_id in number,
    p_integration_type in varchar2,
    p_payload_reference in varchar2,
    p_job_id out number
  ) is
  begin
    insert into integration_job (
      request_id,
      integration_type,
      status,
      attempt_number,
      payload_reference,
      retryable
    ) values (
      p_request_id,
      upper(p_integration_type),
      'READY',
      1,
      p_payload_reference,
      'N'
    ) returning job_id into p_job_id;
  end create_job;

  procedure retry_job(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_job_id in number,
    p_new_job_id out number
  ) is
    l_job integration_job%rowtype;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'ADMIN');

    select *
      into l_job
      from integration_job
     where job_id = p_job_id
     for update;

    if l_job.status <> 'FAILED' or l_job.retryable <> 'Y' then
      raise_application_error(-20060, 'Integration job is not eligible for retry');
    end if;

    insert into integration_job (
      parent_job_id,
      request_id,
      integration_type,
      status,
      attempt_number,
      payload_reference,
      retryable
    ) values (
      l_job.job_id,
      l_job.request_id,
      l_job.integration_type,
      'READY',
      l_job.attempt_number + 1,
      l_job.payload_reference,
      'N'
    ) returning job_id into p_new_job_id;

    if l_job.request_id is not null then
      supplier_workflow_pkg.write_action(
        p_request_id => l_job.request_id,
        p_action => 'RETRY_INTEGRATION_JOB',
        p_from_status => null,
        p_to_status => null,
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'Admin retried failed ' || l_job.integration_type || ' job ' || to_char(l_job.job_id)
      );
    end if;
  end retry_job;

  procedure retry_latest_failed_request_job(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_new_job_id out number
  ) is
    l_job_id number;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'ADMIN');

    select job_id
      into l_job_id
      from integration_job
     where request_id = p_request_id
       and status = 'FAILED'
       and retryable = 'Y'
     order by updated_at desc
     fetch first 1 row only;

    retry_job(
      p_actor_subject_id => p_actor_subject_id,
      p_actor_roles => p_actor_roles,
      p_job_id => l_job_id,
      p_new_job_id => p_new_job_id
    );
  exception
    when no_data_found then
      raise_application_error(-20061, 'No retryable failed job exists for this request');
  end retry_latest_failed_request_job;

  procedure claim_job(
    p_job_id in number,
    p_oic_instance_id in varchar2,
    p_correlation_id in varchar2 default null
  ) is
  begin
    update integration_job
       set status = 'CLAIMED',
           oic_instance_id = p_oic_instance_id,
           correlation_id = p_correlation_id,
           claimed_at = systimestamp,
           started_at = systimestamp,
           updated_at = systimestamp
     where job_id = p_job_id
       and status = 'READY';

    if sql%rowcount = 0 then
      raise_application_error(-20062, 'Integration job is not ready to claim');
    end if;
  end claim_job;

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
  ) is
    l_job integration_job%rowtype;
    l_request_status supplier_request.status%type;
    l_request_version supplier_request.request_version%type;
    l_status varchar2(40);
    l_quality varchar2(30);
  begin
    l_status := upper(p_status);
    l_quality := upper(nvl(p_justification_quality, 'UNKNOWN'));

    if l_quality not in ('LOW', 'MEDIUM', 'HIGH', 'UNKNOWN') then
      l_quality := 'UNKNOWN';
    end if;

    if l_status not in ('SUCCEEDED', 'FAILED', 'CANCELLED') then
      raise_application_error(-20063, 'Unsupported integration completion status');
    end if;

    select *
      into l_job
      from integration_job
     where job_id = p_job_id
     for update;

    update integration_job
       set status = l_status,
           response_reference = p_response_reference,
           error_type = p_error_type,
           error_message = p_error_message,
           retryable = case when upper(nvl(p_retryable, 'N')) = 'Y' then 'Y' else 'N' end,
           completed_at = systimestamp,
           updated_at = systimestamp
     where job_id = p_job_id;

    if l_job.integration_type = 'AI_EXPLANATION' and l_job.request_id is not null then
      select request_version
        into l_request_version
        from supplier_request
       where request_id = l_job.request_id;

      update ai_assessment
         set is_latest = 'N'
       where request_id = l_job.request_id
         and is_latest = 'Y';

      insert into ai_assessment (
        request_id,
        request_version,
        is_latest,
        summary,
        recommended_actions,
        justification_quality,
        model_name,
        status
      ) values (
        l_job.request_id,
        l_request_version,
        'Y',
        coalesce(p_ai_summary, p_error_message, 'AI explanation job completed without summary text.'),
        p_ai_recommended_actions,
        l_quality,
        p_model_name,
        case when l_status = 'SUCCEEDED' then 'SUCCEEDED' else 'FAILED' end
      );
    end if;

    if l_job.integration_type = 'FUSION_CREATE' and l_job.request_id is not null then
      select status
        into l_request_status
        from supplier_request
       where request_id = l_job.request_id;

      if l_request_status = 'APPROVED' then
        supplier_workflow_pkg.transition_request(
          p_request_id => l_job.request_id,
          p_to_status => 'SUBMITTED_TO_FUSION',
          p_action => 'SUBMIT_TO_FUSION',
          p_actor_subject_id => 'OIC_SERVICE',
          p_reason => 'OIC started Fusion supplier creation'
        );
        l_request_status := 'SUBMITTED_TO_FUSION';
      end if;

      if l_status = 'SUCCEEDED' then
        update supplier_request
           set fusion_supplier_id = p_fusion_supplier_id,
               fusion_supplier_number = p_fusion_supplier_number,
               fusion_create_error = null,
               updated_at = systimestamp
         where request_id = l_job.request_id;

        supplier_workflow_pkg.transition_request(
          p_request_id => l_job.request_id,
          p_to_status => 'CREATED_IN_FUSION',
          p_action => 'FUSION_CREATE_SUCCEEDED',
          p_actor_subject_id => 'OIC_SERVICE',
          p_reason => 'Fusion supplier number returned',
          p_existing_supplier_id => p_fusion_supplier_id
        );
      elsif l_status = 'FAILED' and l_request_status = 'SUBMITTED_TO_FUSION' then
        update supplier_request
           set fusion_create_error = p_error_message,
               updated_at = systimestamp
         where request_id = l_job.request_id;

        supplier_workflow_pkg.transition_request(
          p_request_id => l_job.request_id,
          p_to_status => 'INTEGRATION_FAILED',
          p_action => 'FUSION_CREATE_FAILED',
          p_actor_subject_id => 'OIC_SERVICE',
          p_reason => p_error_message
        );
      end if;
    end if;
  end complete_job;
end supplier_integration_pkg;
/
