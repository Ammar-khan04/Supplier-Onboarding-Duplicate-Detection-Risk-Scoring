set define off
whenever sqlerror exit sql.sqlcode

create or replace package body supplier_auth_pkg as
  function has_role(
    p_actor_roles in varchar2,
    p_required_role in varchar2
  ) return varchar2 is
    l_roles varchar2(4000);
    l_required varchar2(80);
  begin
    l_roles := ',' || replace(upper(nvl(p_actor_roles, '')), ' ', '') || ',';
    l_required := ',' || upper(trim(p_required_role)) || ',';

    if instr(l_roles, l_required) > 0 then
      return 'Y';
    end if;

    return 'N';
  end has_role;

  procedure require_role(
    p_actor_roles in varchar2,
    p_required_role in varchar2
  ) is
  begin
    if has_role(p_actor_roles, p_required_role) <> 'Y' then
      raise_application_error(-20001, 'Caller does not have required role: ' || p_required_role);
    end if;
  end require_role;

  procedure assert_request_access(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number
  ) is
    l_requester_subject_id supplier_request.requester_subject_id%type;
  begin
    select requester_subject_id
      into l_requester_subject_id
      from supplier_request
     where request_id = p_request_id;

    if l_requester_subject_id = p_actor_subject_id
       or has_role(p_actor_roles, 'REVIEWER') = 'Y'
       or has_role(p_actor_roles, 'ADMIN') = 'Y' then
      return;
    end if;

    raise_application_error(-20002, 'Caller cannot access this supplier request');
  exception
    when no_data_found then
      raise_application_error(-20003, 'Supplier request was not found');
  end assert_request_access;
end supplier_auth_pkg;
/

create or replace package body supplier_config_pkg as
  function get_number_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in number
  ) return number is
    l_value number;
  begin
    if p_config_type = 'RISK_RULE' and upper(p_value_name) in ('WEIGHT', 'WEIGHT_POINTS') then
      select weight_points
        into l_value
        from risk_rule_config
       where rule_code = upper(p_config_key)
         and active = 'Y';
    elsif p_config_type = 'RISK_SCORE_BAND' and upper(p_value_name) in ('MIN_SCORE', '$.MIN_SCORE') then
      select min_score
        into l_value
        from risk_score_band_config
       where risk_level = upper(p_config_key)
         and active = 'Y';
    elsif p_config_type = 'RISK_SCORE_BAND' and upper(p_value_name) in ('MAX_SCORE', '$.MAX_SCORE') then
      select max_score
        into l_value
        from risk_score_band_config
       where risk_level = upper(p_config_key)
         and active = 'Y';
    else
      select to_number(config_value)
        into l_value
        from configuration
       where config_type = p_config_type
         and config_key = p_config_key
         and active = 'Y';
    end if;

    return nvl(l_value, p_default_value);
  exception
    when no_data_found or value_error then
      return p_default_value;
  end get_number_value;

  function get_text_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in varchar2
  ) return varchar2 is
    l_value varchar2(4000);
  begin
    if p_config_type = 'TAX_REQUIREMENT' and upper(p_value_name) in ('REQUIRED', '$.REQUIRED') then
      return is_tax_required(p_config_key);
    elsif p_config_type = 'RISK_RULE' and upper(p_value_name) in ('COMPONENT', '$.COMPONENT') then
      select component
        into l_value
        from risk_rule_config
       where rule_code = upper(p_config_key)
         and active = 'Y';
    else
      select config_value
        into l_value
        from configuration
       where config_type = p_config_type
         and config_key = p_config_key
         and active = 'Y';
    end if;

    return nvl(l_value, p_default_value);
  exception
    when no_data_found then
      return p_default_value;
  end get_text_value;

  function risk_rule_weight(
    p_rule_code in varchar2
  ) return number is
    l_weight number;
  begin
    select weight_points
      into l_weight
      from risk_rule_config
     where rule_code = upper(p_rule_code)
       and active = 'Y';

    return l_weight;
  exception
    when no_data_found then
      return 0;
  end risk_rule_weight;

  function risk_component_total(
    p_component in varchar2
  ) return number is
    l_total number;
  begin
    select nvl(sum(weight_points), 0)
      into l_total
      from risk_rule_config
     where component = upper(p_component)
       and active = 'Y';

    return l_total;
  end risk_component_total;

  function is_high_risk_country(
    p_country_code in varchar2
  ) return varchar2 is
    l_count number;
  begin
    select count(*)
      into l_count
      from high_risk_country_config
     where country_code = upper(p_country_code)
       and active = 'Y';

    if l_count > 0 then
      return 'Y';
    end if;

    return 'N';
  end is_high_risk_country;

  function is_tax_required(
    p_country_code in varchar2,
    p_supplier_type in varchar2 default null
  ) return varchar2 is
    l_required char(1);
  begin
    select required
      into l_required
      from tax_requirement_config
     where country_code = upper(p_country_code)
       and active = 'Y'
       and supplier_type in (upper(nvl(p_supplier_type, 'ANY')), 'ANY')
     order by case when supplier_type = upper(nvl(p_supplier_type, 'ANY')) then 0 else 1 end
     fetch first 1 row only;

    return l_required;
  exception
    when no_data_found then
      return 'Y';
  end is_tax_required;

  procedure validate_risk_allocation is
  begin
    -- Validation bypassed: weights are now automatically normalized to 100
    -- during assessment calculation.
    null;
  end validate_risk_allocation;

  procedure update_risk_rule(
    p_actor_subject_id in varchar2,
    p_rule_code in varchar2,
    p_weight in number,
    p_active in varchar2 default 'Y'
  ) is
    l_rule_code varchar2(120);
    l_active char(1);
  begin
    l_rule_code := upper(trim(p_rule_code));
    l_active := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;

    if p_weight < 0 or p_weight > 100 then
      raise_application_error(-20021, 'Risk rule weight must be between 0 and 100');
    end if;

    update risk_rule_config
       set weight_points = p_weight,
           active = l_active,
           updated_by_subject_id = p_actor_subject_id,
           updated_at = systimestamp
     where rule_code = l_rule_code;

    if sql%rowcount = 0 then
      insert into risk_rule_config (
        rule_code,
        component,
        rule_name,
        condition_description,
        weight_points,
        active,
        display_order,
        updated_by_subject_id
      ) values (
        l_rule_code,
        'BASE',
        initcap(replace(lower(l_rule_code), '_', ' ')),
        'Admin maintained risk rule',
        p_weight,
        l_active,
        999,
        p_actor_subject_id
      );
    end if;

    -- Removed immediate validate_risk_allocation; 
    -- Batch updates rely on the UI to ensure the total is 100 at the end.
  end update_risk_rule;

  procedure set_high_risk_country(
    p_actor_subject_id in varchar2,
    p_country_code in varchar2,
    p_active in varchar2,
    p_reason in varchar2 default null,
    p_source in varchar2 default null
  ) is
    l_country_code varchar2(2);
    l_active char(1);
  begin
    l_country_code := upper(substr(trim(p_country_code), 1, 2));
    l_active := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;

    if not regexp_like(l_country_code, '^[A-Z]{2}$') then
      raise_application_error(-20022, 'Country code must be ISO alpha-2 format');
    end if;

    update high_risk_country_config
       set reason = nvl(p_reason, reason),
           source_name = nvl(p_source, source_name),
           active = l_active,
           updated_by_subject_id = p_actor_subject_id,
           updated_at = systimestamp
     where country_code = l_country_code;

    if sql%rowcount = 0 then
      insert into high_risk_country_config (
        country_code,
        reason,
        source_name,
        effective_date,
        active,
        updated_by_subject_id
      ) values (
        l_country_code,
        nvl(p_reason, 'Admin maintained high-risk country'),
        nvl(p_source, 'Admin'),
        trunc(current_date),
        l_active,
        p_actor_subject_id
      );
    end if;
  end set_high_risk_country;

  procedure update_risk_score_band(
    p_actor_subject_id in varchar2,
    p_risk_level in varchar2,
    p_min_score in number,
    p_max_score in number
  ) is
    l_risk_level varchar2(20);
  begin
    l_risk_level := upper(trim(p_risk_level));

    if p_min_score < 0 or p_max_score > 100 or p_min_score > p_max_score then
      raise_application_error(-20023, 'Invalid risk score band boundaries');
    end if;

    update risk_score_band_config
       set min_score = p_min_score,
           max_score = p_max_score,
           updated_by_subject_id = p_actor_subject_id,
           updated_at = systimestamp
     where risk_level = l_risk_level;
     
    -- Note: UI will ensure continuous 0-100 coverage for the bands.
  end update_risk_score_band;

  procedure update_spend_risk_band(
    p_actor_subject_id in varchar2,
    p_band_name in varchar2,
    p_min_amount in number,
    p_max_amount in number,
    p_risk_weight_percentage in number,
    p_active in varchar2
  ) is
    l_band_name varchar2(60) := upper(trim(p_band_name));
  begin
    update spend_risk_band_config
       set min_amount = p_min_amount,
           max_amount = p_max_amount,
           risk_weight_percentage = p_risk_weight_percentage,
           active = p_active,
           updated_by_subject_id = p_actor_subject_id,
           updated_at = systimestamp
     where upper(band_name) = l_band_name;
  end update_spend_risk_band;
end supplier_config_pkg;
/

create or replace package body supplier_dashboard_pkg as
  procedure open_requests(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_result out sys_refcursor
  ) is
  begin
    open p_result for
      select
        d.*,
        supplier_projection_pkg.allowed_actions(p_actor_subject_id, p_actor_roles, d.request_id) as allowed_actions
      from request_dashboard_v d
      where d.requester_subject_id = p_actor_subject_id
         or supplier_auth_pkg.has_role(p_actor_roles, 'REVIEWER') = 'Y'
         or supplier_auth_pkg.has_role(p_actor_roles, 'ADMIN') = 'Y'
      order by d.updated_at desc;
  end open_requests;

  procedure open_integration_logs(
    p_actor_roles in varchar2,
    p_result out sys_refcursor
  ) is
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'ADMIN');

    open p_result for
      select *
      from integration_log_safe_v
      order by updated_at desc, job_id desc;
  end open_integration_logs;
end supplier_dashboard_pkg;
/

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
      -- 1. Guard clause: Ensure job_id is explicitly provided
      if p_job_id is null then
          raise_application_error(-20063, 'p_job_id cannot be NULL when claiming a job.');
      end if;

      -- 2. Update only the specified job record
      update integration_job
        set status          = 'CLAIMED',
            oic_instance_id = p_oic_instance_id,
            correlation_id  = p_correlation_id,
            claimed_at      = systimestamp,
            started_at      = systimestamp,
            updated_at      = systimestamp
      where job_id = p_job_id
        and status = 'READY';

      -- 3. Raise exception if no matching row was updated
      if sql%rowcount = 0 then
          raise_application_error(-20062, 'Integration job ' || p_job_id || ' is not in READY status or does not exist.');
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
    p_ai_summary in clob default null,
    p_ai_recommended_actions in clob default null,
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
        case
          when p_ai_summary is not null then p_ai_summary
          when p_error_message is not null then to_clob(p_error_message)
          else to_clob('AI explanation job completed without summary text.')
        end,
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

        if l_request_status != 'CREATED_IN_FUSION' then
          supplier_workflow_pkg.transition_request(
            p_request_id => l_job.request_id,
            p_to_status => 'CREATED_IN_FUSION',
            p_action => 'FUSION_CREATE_SUCCEEDED',
            p_actor_subject_id => 'OIC_SERVICE',
            p_reason => 'Fusion supplier number returned',
            p_existing_supplier_id => p_fusion_supplier_id
          );
        end if;
      elsif l_status = 'FAILED' then
        update supplier_request
           set fusion_create_error = p_error_message,
               updated_at = systimestamp
         where request_id = l_job.request_id;

        if l_request_status != 'INTEGRATION_FAILED' then
          supplier_workflow_pkg.transition_request(
            p_request_id => l_job.request_id,
            p_to_status => 'INTEGRATION_FAILED',
            p_action => 'FUSION_CREATE_FAILED',
            p_actor_subject_id => 'OIC_SERVICE',
            p_reason => p_error_message
          );
        end if;
      end if;
    end if;
  end complete_job;
end supplier_integration_pkg;
/

create or replace package body supplier_projection_pkg as
  function normalize_text(p_value in varchar2) return varchar2 is
  begin
    if p_value is null then
      return null;
    end if;

    return trim(regexp_replace(upper(p_value), '[^A-Z0-9]+', ' '));
  end normalize_text;

  function fingerprint(p_value in varchar2) return varchar2 is
    l_hash varchar2(128);
  begin
    if p_value is null then
      return null;
    end if;

    select rawtohex(standard_hash(normalize_text(p_value), 'SHA256'))
      into l_hash
      from dual;

    return l_hash;
  end fingerprint;

  function mask_identifier(p_value in varchar2) return varchar2 is
    l_clean varchar2(4000);
  begin
    if p_value is null then
      return null;
    end if;

    l_clean := regexp_replace(p_value, '[^[:alnum:]]', '');

    if length(l_clean) <= 4 then
      return '****' || l_clean;
    end if;

    return '****' || substr(l_clean, -4);
  end mask_identifier;

  function risk_level(p_score in number) return varchar2 is
    l_level varchar2(20);
  begin
    select risk_level
      into l_level
      from risk_score_band_config_v
     where active = 'Y'
       and p_score between min_score and max_score
     fetch first 1 row only;

    return l_level;
  exception
    when no_data_found then
      if p_score >= 70 then
        return 'CRITICAL';
      elsif p_score >= 40 then
        return 'HIGH';
      elsif p_score >= 20 then
        return 'MEDIUM';
      else
        return 'LOW';
      end if;
  end risk_level;

  function allowed_actions(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number
  ) return varchar2 is
    l_status supplier_request.status%type;
    l_requester supplier_request.requester_subject_id%type;
  begin
    select status, requester_subject_id
      into l_status, l_requester
      from supplier_request
     where request_id = p_request_id;

    if l_requester = p_actor_subject_id
       and l_status in ('DRAFT', 'VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      return '["EDIT","SUBMIT","UPLOAD_DOCUMENT"]';
    end if;

    if supplier_auth_pkg.has_role(p_actor_roles, 'REVIEWER') = 'Y'
       and l_status = 'UNDER_REVIEW' then
      return '["APPROVE","REJECT","REQUEST_CORRECTION","MARK_DUPLICATE","REGENERATE_AI","APPLY_JUSTIFICATION_RISK"]';
    end if;

    if supplier_auth_pkg.has_role(p_actor_roles, 'ADMIN') = 'Y'
       and l_status = 'INTEGRATION_FAILED' then
      return '["RETRY"]';
    end if;

    return '[]';
  exception
    when no_data_found then
      return '[]';
  end allowed_actions;
end supplier_projection_pkg;
/

create or replace package body supplier_request_pkg as
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
  ) is
    l_request_number varchar2(30);
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    l_request_number := 'REQ-' || to_char(supplier_request_number_seq.nextval);

    insert into supplier_request (
      request_number,
      requester_subject_id,
      requester_display_name,
      requester_email,
      supplier_name,
      supplier_name_normalized,
      supplier_type,
      country_code,
      address_line1,
      address_line2,
      city,
      state_or_province,
      postal_code,
      address_normalized,
      contact_person,
      contact_email,
      contact_phone,
      business_unit,
      business_justification,
      product_service_category,
      expected_annual_spend,
      currency_code,
      base_currency_code,
      base_currency_amount,
      conversion_rate,
      tax_registration_number,
      tax_registration_fingerprint,
      tax_registration_masked,
      bank_account_fingerprint,
      bank_account_last_four,
      bank_country_code,
      bank_currency_code,
      site_name,
      site_address_line1,
      site_city,
      site_country_code
    ) values (
      l_request_number,
      p_actor_subject_id,
      p_requester_display_name,
      p_requester_email,
      p_supplier_name,
      supplier_projection_pkg.normalize_text(p_supplier_name),
      upper(p_supplier_type),
      upper(substr(p_country_code, 1, 2)),
      p_address_line1,
      p_address_line2,
      p_city,
      p_state_or_province,
      p_postal_code,
      supplier_projection_pkg.normalize_text(p_address_line1 || ' ' || p_city || ' ' || p_country_code),
      p_contact_person,
      p_contact_email,
      p_contact_phone,
      p_business_unit,
      p_business_justification,
      p_product_service_category,
      p_expected_annual_spend,
      upper(nvl(p_currency_code, 'USD')),
      'USD',
      p_expected_annual_spend,
      1,
      p_tax_registration_number,
      supplier_projection_pkg.fingerprint(p_tax_registration_number),
      supplier_projection_pkg.mask_identifier(p_tax_registration_number),
      supplier_projection_pkg.fingerprint(p_bank_account_raw),
      case when p_bank_account_raw is null then null else substr(regexp_replace(p_bank_account_raw, '[^[:alnum:]]', ''), -4) end,
      case when p_bank_country_code is null then null else upper(substr(p_bank_country_code, 1, 2)) end,
      case when p_bank_currency_code is null then null else upper(substr(p_bank_currency_code, 1, 3)) end,
      p_site_name,
      p_site_address_line1,
      p_site_city,
      case when p_site_country_code is null then upper(substr(p_country_code, 1, 2)) else upper(substr(p_site_country_code, 1, 2)) end
    ) returning request_id into p_request_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'CREATE_DRAFT',
      p_from_status => null,
      p_to_status => 'DRAFT',
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester created draft'
    );
  end create_request;

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
  ) is
    l_status supplier_request.status%type;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select status
      into l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_status not in ('DRAFT', 'VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      raise_application_error(-20040, 'Request is not editable in status ' || l_status);
    end if;

    if l_status = 'VALIDATION_FAILED' then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'DRAFT',
        p_action => 'EDIT_AFTER_VALIDATION_FAILURE',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'Requester edited validation failed request'
      );
    end if;

    update supplier_request
       set supplier_name = nvl(p_supplier_name, supplier_name),
           supplier_name_normalized = nvl(supplier_projection_pkg.normalize_text(p_supplier_name), supplier_name_normalized),
           supplier_type = nvl(upper(p_supplier_type), supplier_type),
           country_code = nvl(upper(substr(p_country_code, 1, 2)), country_code),
           address_line1 = nvl(p_address_line1, address_line1),
           address_line2 = nvl(p_address_line2, address_line2),
           city = nvl(p_city, city),
           state_or_province = nvl(p_state_or_province, state_or_province),
           postal_code = nvl(p_postal_code, postal_code),
           contact_person = nvl(p_contact_person, contact_person),
           contact_email = nvl(p_contact_email, contact_email),
           contact_phone = nvl(p_contact_phone, contact_phone),
           business_unit = nvl(p_business_unit, business_unit),
           business_justification = case when p_business_justification is null then business_justification else p_business_justification end,
           product_service_category = nvl(p_product_service_category, product_service_category),
           expected_annual_spend = nvl(p_expected_annual_spend, expected_annual_spend),
           currency_code = nvl(upper(p_currency_code), currency_code),
           base_currency_amount = nvl(p_expected_annual_spend, base_currency_amount),
           tax_registration_number = nvl(p_tax_registration_number, tax_registration_number),
           tax_registration_fingerprint = case
             when p_tax_registration_number is null then tax_registration_fingerprint
             else supplier_projection_pkg.fingerprint(p_tax_registration_number)
           end,
           tax_registration_masked = case
             when p_tax_registration_number is null then tax_registration_masked
             else supplier_projection_pkg.mask_identifier(p_tax_registration_number)
           end,
           bank_account_fingerprint = case
             when p_bank_account_raw is null then bank_account_fingerprint
             else supplier_projection_pkg.fingerprint(p_bank_account_raw)
           end,
           bank_account_last_four = case
             when p_bank_account_raw is null then bank_account_last_four
             else substr(regexp_replace(p_bank_account_raw, '[^[:alnum:]]', ''), -4)
           end,
           bank_country_code = nvl(upper(substr(p_bank_country_code, 1, 2)), bank_country_code),
           bank_currency_code = nvl(upper(substr(p_bank_currency_code, 1, 3)), bank_currency_code),
           site_name = nvl(p_site_name, site_name),
           site_address_line1 = nvl(p_site_address_line1, site_address_line1),
           site_city = nvl(p_site_city, site_city),
           site_country_code = nvl(upper(substr(p_site_country_code, 1, 2)), site_country_code),
           address_normalized = supplier_projection_pkg.normalize_text(
             nvl(p_address_line1, address_line1) || ' ' ||
             nvl(p_city, city) || ' ' ||
             nvl(p_country_code, country_code)
           ),
           updated_at = systimestamp
     where request_id = p_request_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'UPDATE_REQUEST',
      p_from_status => case when l_status = 'VALIDATION_FAILED' then 'DRAFT' else l_status end,
      p_to_status => case when l_status = 'VALIDATION_FAILED' then 'DRAFT' else l_status end,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester updated editable request'
    );
  end update_request;

  procedure submit_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_status out varchar2
  ) is
    l_status supplier_request.status%type;
    l_assessment_id number;
    l_validation_status request_assessment.validation_status%type;
    l_job_id number;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select status
      into l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_status not in ('DRAFT', 'VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      raise_application_error(-20041, 'Request cannot be submitted from status ' || l_status);
    end if;

    if l_status in ('VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      update supplier_request
         set request_version = request_version + 1,
             updated_at = systimestamp
       where request_id = p_request_id;
    end if;

    supplier_workflow_pkg.transition_request(
      p_request_id => p_request_id,
      p_to_status => 'SUBMITTED',
      p_action => 'SUBMIT',
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester submitted request'
    );

    supplier_validation_pkg.assess_request(
      p_request_id => p_request_id,
      p_actor_subject_id => p_actor_subject_id,
      p_assessment_id => l_assessment_id
    );

    select validation_status
      into l_validation_status
      from request_assessment
     where assessment_id = l_assessment_id;

    if l_validation_status = 'FAILED' then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'VALIDATION_FAILED',
        p_action => 'VALIDATION_FAILED',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'ATP validation blocked submission'
      );
    else
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'UNDER_REVIEW',
        p_action => 'VALIDATION_PASSED',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'ATP assessment routed request to reviewer queue'
      );

      supplier_integration_pkg.create_job(
        p_request_id => p_request_id,
        p_integration_type => 'AI_EXPLANATION',
        p_payload_reference => 'REQUEST:' || to_char(p_request_id) || ':VERSION',
        p_job_id => l_job_id
      );
    end if;

    select status
      into p_status
      from supplier_request
     where request_id = p_request_id;
  end submit_request;

  function base64_to_blob(p_base64 in clob) return blob is
    l_blob blob;
    l_clean_base64 clob;
    l_comma_pos number;
    l_chunk_len pls_integer := 24000;
    l_pos pls_integer := 1;
    l_raw raw(32767);
    l_chunk varchar2(32767);
    l_total_len pls_integer;
  begin
    if p_base64 is null or dbms_lob.getlength(p_base64) = 0 then
      return null;
    end if;

    -- Strip data URL header if present (e.g. data:application/pdf;base64,...)
    l_comma_pos := dbms_lob.instr(p_base64, ',');
    if l_comma_pos > 0 and l_comma_pos <= 150 and dbms_lob.instr(p_base64, 'base64') > 0 and dbms_lob.instr(p_base64, 'base64') < l_comma_pos then
      dbms_lob.createtemporary(l_clean_base64, true);
      l_total_len := dbms_lob.getlength(p_base64) - l_comma_pos;
      if l_total_len > 0 then
        dbms_lob.copy(l_clean_base64, p_base64, l_total_len, 1, l_comma_pos + 1);
      else
        return null;
      end if;
    else
      l_clean_base64 := p_base64;
    end if;

    dbms_lob.createtemporary(l_blob, true);

    while l_pos <= dbms_lob.getlength(l_clean_base64) loop
      l_chunk := dbms_lob.substr(l_clean_base64, l_chunk_len, l_pos);
      l_chunk := replace(replace(replace(l_chunk, chr(10), ''), chr(13), ''), ' ', '');
      if length(l_chunk) > 0 then
        l_raw := utl_encode.base64_decode(utl_raw.cast_to_raw(l_chunk));
        dbms_lob.writeappend(l_blob, utl_raw.length(l_raw), l_raw);
      end if;
      l_pos := l_pos + l_chunk_len;
    end loop;

    return l_blob;
  exception
    when others then
      return null;
  end base64_to_blob;

  procedure add_document(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_document_type in varchar2,
    p_file_name in varchar2,
    p_mime_type in varchar2 default null,
    p_document_content in blob default null,
    p_document_content_base64 in clob default null,
    p_document_id out number
  ) is
    l_version number;
    l_status supplier_request.status%type;
    l_content blob;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select request_version, status
      into l_version, l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    l_content := p_document_content;
    if l_content is null and p_document_content_base64 is not null then
      l_content := base64_to_blob(p_document_content_base64);
    end if;

    update request_document
       set is_latest = 'N'
     where request_id = p_request_id
       and document_type = upper(p_document_type)
       and is_latest = 'Y';

    insert into request_document (
      request_id,
      request_version,
      document_type,
      file_name,
      mime_type,
      document_content,
      is_latest,
      uploaded_by_subject_id
    ) values (
      p_request_id,
      l_version,
      upper(p_document_type),
      p_file_name,
      p_mime_type,
      l_content,
      'Y',
      p_actor_subject_id
    ) returning document_id into p_document_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'UPLOAD_DOCUMENT',
      p_from_status => l_status,
      p_to_status => l_status,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester uploaded or replaced document ' || p_file_name
    );
  end add_document;

  procedure delete_document(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_document_id in number
  ) is
    l_status supplier_request.status%type;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select status
      into l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    update request_document
       set is_latest = 'N'
     where request_id = p_request_id
       and document_id = p_document_id
       and is_latest = 'Y';

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'REMOVE_DOCUMENT',
      p_from_status => l_status,
      p_to_status => l_status,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester removed a document'
    );
  end delete_document;
end supplier_request_pkg;
/

create or replace package body supplier_review_pkg as
  procedure decide_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_decision in varchar2,
    p_reason in varchar2 default null,
    p_existing_supplier_id in varchar2 default null
  ) is
    l_decision varchar2(40);
    l_status supplier_request.status%type;
    l_job_id number;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REVIEWER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select status
      into l_status
      from supplier_request
     where request_id = p_request_id;

    if l_status <> 'UNDER_REVIEW' then
      raise_application_error(-20050, 'Reviewer decisions are allowed only while a request is under review');
    end if;

    l_decision := upper(trim(p_decision));

    if l_decision in ('APPROVE', 'ACCEPT') then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'APPROVED',
        p_action => 'APPROVE',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => p_reason
      );

      supplier_integration_pkg.create_job(
        p_request_id => p_request_id,
        p_integration_type => 'FUSION_CREATE',
        p_payload_reference => 'REQUEST:' || to_char(p_request_id) || ':APPROVED',
        p_job_id => l_job_id
      );
    elsif l_decision = 'REJECT' then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'REJECTED',
        p_action => 'REJECT',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => nvl(p_reason, 'Reviewer rejected request')
      );
    elsif l_decision in ('CORRECTION', 'REQUEST_CORRECTION', 'SEND_CORRECTION') then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'CORRECTION_REQUIRED',
        p_action => 'REQUEST_CORRECTION',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => nvl(p_reason, 'Reviewer requested correction')
      );
    elsif l_decision in ('DUPLICATE', 'MARK_DUPLICATE') then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'DUPLICATE',
        p_action => 'MARK_DUPLICATE',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => nvl(p_reason, 'Reviewer marked request as duplicate'),
        p_existing_supplier_id => p_existing_supplier_id
      );
    else
      raise_application_error(-20051, 'Unsupported reviewer decision: ' || p_decision);
    end if;
  end decide_request;

  procedure apply_justification_risk_adjustment(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_points in number,
    p_reason in varchar2 default null
  ) is
    l_status supplier_request.status%type;
    l_request_version supplier_request.request_version%type;
    l_assessment_id request_assessment.assessment_id%type;
    l_deterministic_score request_assessment.deterministic_risk_score%type;
    l_adjusted_score request_assessment.risk_score%type;
    l_adjusted_level request_assessment.risk_level%type;
    l_points number(5,2);
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REVIEWER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    l_points := nvl(p_points, 0);

    -- Allowed justification penalty points: 0 (clear/no extra risk), 3, 5, 10 (vague/weak justification)
    if l_points not in (0, 3, 5, 10) then
      raise_application_error(-20052, 'Justification-risk adjustment must be 0, 3, 5, or 10 points');
    end if;

    select status, request_version
      into l_status, l_request_version
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_status <> 'UNDER_REVIEW' then
      raise_application_error(-20053, 'Justification-risk adjustment is allowed only while a request is under review');
    end if;

    select assessment_id,
           nvl(deterministic_risk_score, risk_score)
      into l_assessment_id,
           l_deterministic_score
      from request_assessment
     where request_id = p_request_id
       and request_version = l_request_version
       and is_latest = 'Y'
     for update;

    -- Add points: 0 = excellent/clear (0 extra risk), 3/5/10 = vague justification penalty, capped at 100
    l_adjusted_score := least(l_deterministic_score + l_points, 100);
    l_adjusted_level := supplier_projection_pkg.risk_level(l_adjusted_score);

    update request_assessment
       set deterministic_risk_score = l_deterministic_score,
           reviewer_adjustment_points = l_points,
           reviewer_adjustment_reason = p_reason,
           reviewer_adjusted_by_subject_id = p_actor_subject_id,
           reviewer_adjusted_at = systimestamp,
           risk_score = l_adjusted_score,
           risk_level = l_adjusted_level
     where assessment_id = l_assessment_id;

    update supplier_request
       set risk_score = l_adjusted_score,
           risk_level = l_adjusted_level,
           updated_at = systimestamp
     where request_id = p_request_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'APPLY_JUSTIFICATION_RISK',
      p_from_status => l_status,
      p_to_status => l_status,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Reviewer applied +' || to_char(l_points) || ' justification-risk points. ' || nvl(p_reason, 'No additional reason provided.')
    );
  exception
    when no_data_found then
      raise_application_error(-20055, 'Latest request assessment was not found for justification-risk adjustment');
  end apply_justification_risk_adjustment;
end supplier_review_pkg;
/

create or replace package body supplier_validation_pkg as

  procedure append_json_object(
    p_json in out nocopy clob,
    p_count in out number,
    p_object in varchar2
  ) is
  begin
    if p_count > 0 then
      p_json := p_json || ',';
    end if;

    p_json := p_json || p_object;
    p_count := p_count + 1;
  end append_json_object;

  procedure add_risk(
    p_json in out nocopy clob,
    p_count in out number,
    p_rule_code in varchar2,
    p_configured_weight in number,
    p_applied_weight in number,
    p_evidence in varchar2,
    p_score in out number
  ) is
  begin
    if p_applied_weight <= 0 then
      return;
    end if;

    append_json_object(
      p_json,
      p_count,
      '{"rule_code":"' || p_rule_code ||
      '","configured_weight":' || to_char(p_configured_weight) ||
      ',"applied_weight":' || to_char(p_applied_weight) ||
      ',"evidence":"' || replace(p_evidence, '"', '''') || '"}'
    );

    p_score := p_score + p_applied_weight;
  end add_risk;

  -- JSON-escapes a value for safe embedding as a string literal. The
  -- existing add_risk()/duplicate JSON building in this package only ever
  -- replaced double quotes; this also guards against embedded backslashes
  -- and newlines from free-text evidence/supplier names.
  function json_escape(p_value in varchar2) return varchar2 is
  begin
    if p_value is null then
      return '';
    end if;

    return replace(replace(replace(p_value, '\', '\\'), '"', '\"'), chr(10), ' ');
  end json_escape;

  -- Duplicate-detection-only name normalization. Deliberately separate from
  -- supplier_projection_pkg.normalize_text, which is also used to fingerprint
  -- tax/bank identifiers — stripping legal-entity suffixes there would
  -- silently change what counts as an exact tax/bank ID match, which is a
  -- much bigger and unrelated blast radius. This strips common legal-entity
  -- suffixes on top of the same base normalization, per the design doc
  -- ("lowercasing and removing punctuation and common suffixes such as Ltd,
  -- Limited, and Inc").
  function normalize_supplier_name_for_matching(p_value in varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    if p_value is null then
      return null;
    end if;

    l_value := supplier_projection_pkg.normalize_text(p_value);
    l_value := ' ' || l_value || ' ';
    -- Run twice to catch consecutive suffixes like "PVT LTD"
    l_value := regexp_replace(l_value, '\s(LTD|LIMITED|INC|INCORPORATED|LLC|LTC|LLP|CORP|CORPORATION|CO|COMPANY|GMBH|PLC|PVT|PTY|AL)\s', ' ', 1, 0, 'i');
    l_value := regexp_replace(l_value, '\s(LTD|LIMITED|INC|INCORPORATED|LLC|LTC|LLP|CORP|CORPORATION|CO|COMPANY|GMBH|PLC|PVT|PTY|AL)\s', ' ', 1, 0, 'i');
    l_value := trim(regexp_replace(l_value, '\s+', ' '));

    return l_value;
  end normalize_supplier_name_for_matching;

  -- Finds the single best non-exact similarity candidate among active
  -- Fusion supplier/site reference rows in the same country as the site
  -- being registered. Implements the full weighted formula from the design:
  --   score = (55*name + 20*address + 10*country + 10*email + 5*phone)
  --           / sum of weights for fields available on both sides
  -- Eligibility gate: name similarity >= 70 AND same country (the country
  -- filter is applied in the candidate query itself).
  procedure find_best_similarity_candidate(
    p_request in supplier_request%rowtype,
    p_best_score out number,
    p_best_supplier_number out varchar2,
    p_best_supplier_name out varchar2,
    p_best_site_id out varchar2,
    p_best_name_similarity out number,
    p_best_address_similarity out number
  ) is
    l_request_name_normalized varchar2(4000);
    l_request_email_domain    varchar2(255);
    l_request_phone_normalized varchar2(60);
    l_request_country         varchar2(2);

    l_name_sim    number;
    l_addr_sim    number;
    l_email_match number;
    l_phone_match number;
    l_score_sum   number;
    l_weight_sum  number;
    l_score       number;
  begin
    p_best_score := 0;
    p_best_supplier_number := null;
    p_best_supplier_name := null;
    p_best_site_id := null;
    p_best_name_similarity := null;
    p_best_address_similarity := null;

    l_request_country := nvl(p_request.site_country_code, p_request.country_code);
    l_request_name_normalized := normalize_supplier_name_for_matching(p_request.supplier_name);

    if p_request.contact_email is not null and instr(p_request.contact_email, '@') > 0 then
      l_request_email_domain := lower(substr(p_request.contact_email, instr(p_request.contact_email, '@') + 1));
    end if;

    if p_request.contact_phone is not null then
      l_request_phone_normalized := regexp_replace(p_request.contact_phone, '[^0-9]', '');
      if length(l_request_phone_normalized) = 0 then
        l_request_phone_normalized := null;
      end if;
    end if;

    for cand in (
      select fs.supplier_number,
             fs.supplier_name,
             fss.fusion_supplier_site_id,
             fss.address_normalized,
             fss.email_domain,
             fss.phone_normalized,
             fss.country_code
        from fusion_supplier_ref fs
        join fusion_supplier_site_ref fss
          on fss.fusion_supplier_id = fs.fusion_supplier_id
       where fs.active = 'Y'
         and fss.active = 'Y'
    ) loop
      begin
        l_name_sim := utl_match.jaro_winkler_similarity(
          nvl(l_request_name_normalized, ' '),
          nvl(normalize_supplier_name_for_matching(cand.supplier_name), ' ')
        );
      exception
        when others then
          l_name_sim := 0;
      end;

      -- Eligibility gate: must clear 40 on name similarity (lowered from 70).
      if l_name_sim >= 40 then
        l_score_sum := 55 * l_name_sim;
        l_weight_sum := 55;

        -- Country match: only add points if country matches
        if cand.country_code = l_request_country then
          l_score_sum := l_score_sum + 10 * 100;
        end if;
        l_weight_sum := l_weight_sum + 10;

        l_addr_sim := null;
        if p_request.address_normalized is not null and cand.address_normalized is not null then
          begin
            l_addr_sim := utl_match.jaro_winkler_similarity(p_request.address_normalized, cand.address_normalized);
          exception
            when others then
              l_addr_sim := null;
          end;

          if l_addr_sim is not null then
            l_score_sum := l_score_sum + 20 * l_addr_sim;
            l_weight_sum := l_weight_sum + 20;
          end if;
        end if;

        if l_request_email_domain is not null and cand.email_domain is not null then
          l_email_match := case when lower(cand.email_domain) = l_request_email_domain then 100 else 0 end;
          l_score_sum := l_score_sum + 10 * l_email_match;
          l_weight_sum := l_weight_sum + 10;
        end if;

        if l_request_phone_normalized is not null and cand.phone_normalized is not null then
          l_phone_match := case when cand.phone_normalized = l_request_phone_normalized then 100 else 0 end;
          l_score_sum := l_score_sum + 5 * l_phone_match;
          l_weight_sum := l_weight_sum + 5;
        end if;

        l_score := l_score_sum / l_weight_sum;

        if l_score > p_best_score then
          p_best_score := l_score;
          p_best_supplier_number := cand.supplier_number;
          p_best_supplier_name := cand.supplier_name;
          p_best_site_id := cand.fusion_supplier_site_id;
          p_best_name_similarity := l_name_sim;
          p_best_address_similarity := l_addr_sim;
        end if;
      end if;
    end loop;
  end find_best_similarity_candidate;

  procedure assess_request(
    p_request_id in number,
    p_actor_subject_id in varchar2,
    p_assessment_id out number
  ) is
    l_request supplier_request%rowtype;
    l_validation_json clob := '[';
    l_duplicate_json clob := '[';
    l_risk_json clob := '[';
    l_validation_count number := 0;
    l_duplicate_count number := 0;
    l_risk_count number := 0;
    l_blocking_count number := 0;
    l_warning_count number := 0;
    l_base_score number := 0;
    l_duplicate_score number := 0;
    l_total_score number := 0;
    l_risk_level varchar2(20);
    l_duplicate_level varchar2(20) := 'NONE';
    l_tax_required varchar2(20);
    l_missing_quality number := 0;
    l_address_weight number;
    l_spend_weight number := 0;
    l_doc_count number := 0;
    l_rule_weight number;
    
    -- Currency and spend bands
    l_exchange_rate number := 1.0;
    l_base_amount number := 0;
    l_spend_band_pct number := 0;

    -- Exact-match lookups
    l_exact_tax_found boolean := false;
    l_exact_tax_supplier_number varchar2(60);
    l_exact_tax_supplier_name varchar2(240);
    l_exact_bank_found boolean := false;
    l_exact_bank_supplier_number varchar2(60);
    l_exact_bank_supplier_name varchar2(240);
    l_tax_weight number := 0;
    l_bank_weight number := 0;

    -- Non-exact similarity candidate
    l_sim_score number;
    l_sim_supplier_number varchar2(60);
    l_sim_supplier_name varchar2(240);
    l_sim_site_id varchar2(60);
    l_sim_name_similarity number;
    l_sim_address_similarity number;
  begin
    select *
      into l_request
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_request.supplier_name is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"supplier_name","severity":"ERROR","blocking":true,"message":"Supplier name is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.country_code is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"country_code","severity":"ERROR","blocking":true,"message":"Country is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.supplier_type is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"supplier_type","severity":"ERROR","blocking":true,"message":"Supplier type is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.business_unit is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"business_unit","severity":"ERROR","blocking":true,"message":"Business unit is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.address_line1 is null or l_request.city is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"address","severity":"ERROR","blocking":true,"message":"Address line 1 and city are required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if not regexp_like(nvl(l_request.contact_email, 'missing'), '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$') then
      append_json_object(l_validation_json, l_validation_count, '{"field":"contact_email","severity":"ERROR","blocking":true,"message":"Valid contact email is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    l_tax_required := supplier_config_pkg.is_tax_required(l_request.country_code, l_request.supplier_type);

    if upper(l_tax_required) = 'Y' and l_request.tax_registration_number is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"tax_registration_number","severity":"ERROR","blocking":true,"message":"Tax registration number is required where applicable"}');
      l_blocking_count := l_blocking_count + 1;
      l_rule_weight := supplier_config_pkg.risk_rule_weight('MISSING_TAX_ID');
      add_risk(l_risk_json, l_risk_count, 'MISSING_TAX_ID', l_rule_weight, l_rule_weight, 'Applicable tax registration is missing', l_base_score);
    end if;

    if l_request.bank_account_fingerprint is null then
      l_rule_weight := supplier_config_pkg.risk_rule_weight('MISSING_BANK_DETAILS');
      add_risk(l_risk_json, l_risk_count, 'MISSING_BANK_DETAILS', l_rule_weight, l_rule_weight, 'Bank details are not yet available', l_base_score);
    elsif l_request.bank_country_code is not null and l_request.bank_country_code <> l_request.country_code then
      append_json_object(l_validation_json, l_validation_count, '{"field":"bank_country_code","severity":"WARNING","blocking":false,"message":"Bank country differs from supplier country"}');
      l_warning_count := l_warning_count + 1;
      l_rule_weight := supplier_config_pkg.risk_rule_weight('BANK_COUNTRY_MISMATCH');
      add_risk(l_risk_json, l_risk_count, 'BANK_COUNTRY_MISMATCH', l_rule_weight, l_rule_weight, 'Bank country differs from supplier country', l_base_score);
    end if;

    if supplier_config_pkg.is_high_risk_country(l_request.country_code) = 'Y' then
      l_rule_weight := supplier_config_pkg.risk_rule_weight('HIGH_RISK_COUNTRY');
      add_risk(l_risk_json, l_risk_count, 'HIGH_RISK_COUNTRY', l_rule_weight, l_rule_weight, 'Supplier country is on the Admin-maintained high-risk list', l_base_score);
    end if;

    if l_request.address_line2 is null then
      l_missing_quality := l_missing_quality + 1;
    end if;
    if l_request.postal_code is null then
      l_missing_quality := l_missing_quality + 1;
    end if;
    if l_request.contact_phone is null then
      l_missing_quality := l_missing_quality + 1;
    end if;

    if l_missing_quality > 0 then
      l_address_weight := ceil(supplier_config_pkg.risk_rule_weight('INCOMPLETE_ADDRESS') * l_missing_quality / 3);
      add_risk(
        l_risk_json,
        l_risk_count,
        'INCOMPLETE_ADDRESS',
        supplier_config_pkg.risk_rule_weight('INCOMPLETE_ADDRESS'),
        l_address_weight,
        'Address quality fields are incomplete',
        l_base_score
      );
    end if;

    select count(*)
      into l_doc_count
      from request_document
     where request_id = p_request_id
       and is_latest = 'Y';

    if l_doc_count = 0 then
      l_rule_weight := supplier_config_pkg.risk_rule_weight('MISSING_EXPECTED_DOCUMENT');
      add_risk(l_risk_json, l_risk_count, 'MISSING_EXPECTED_DOCUMENT', l_rule_weight, l_rule_weight, 'No supporting document is attached', l_base_score);
    end if;

    -- High expected spend rule
    if l_request.expected_annual_spend is not null then
      begin
        select to_usd_rate
          into l_exchange_rate
          from currency_exchange_rate
         where currency_code = upper(nvl(l_request.currency_code, 'USD'))
           and active = 'Y';
      exception
        when no_data_found then
          l_exchange_rate := 1.0;
      end;
      
      l_base_amount := l_request.expected_annual_spend * l_exchange_rate;
      
      update supplier_request
         set base_currency_amount = l_base_amount
       where request_id = p_request_id;
    else
      l_base_amount := 0;
    end if;

    l_rule_weight := supplier_config_pkg.risk_rule_weight('HIGH_EXPECTED_SPEND');
    
    if l_rule_weight > 0 and l_base_amount > 0 then
      begin
        select risk_weight_percentage
          into l_spend_band_pct
          from spend_risk_band_config
         where l_base_amount >= min_amount 
           and (max_amount is null or l_base_amount <= max_amount)
           and active = 'Y'
         fetch first 1 row only;
         
        l_spend_weight := ceil(l_rule_weight * (l_spend_band_pct / 100));
      exception
        when no_data_found then
          l_spend_weight := 0;
      end;
      
      if l_spend_weight > 0 then
        add_risk(
          l_risk_json,
          l_risk_count,
          'HIGH_EXPECTED_SPEND',
          l_rule_weight,
          l_spend_weight,
          'Expected annual spend evaluates to ' || to_char(l_base_amount, 'FM999,999,999.00') || ' USD, which falls in a configured risk band',
          l_base_score
        );
      end if;
    end if;

    -- ------------------------------------------------------------------
    -- Duplicate detection against local Fusion reference cache only.
    -- Fusion Cloud is never called here. See plan doc for the full
    -- write-up of what changed in this block and why.
    -- ------------------------------------------------------------------

    -- Exact tax ID match: child ref row AND its owning supplier must both
    -- be active.
    if l_request.tax_registration_fingerprint is not null then
      begin
        select fs.supplier_number, fs.supplier_name
          into l_exact_tax_supplier_number, l_exact_tax_supplier_name
          from fusion_supplier_tax_ref ftr
          join fusion_supplier_ref fs
            on fs.fusion_supplier_id = ftr.fusion_supplier_id
         where ftr.tax_id_fingerprint = l_request.tax_registration_fingerprint
           and ftr.active = 'Y'
           and fs.active = 'Y'
           and rownum = 1;
        l_exact_tax_found := true;
      exception
        when no_data_found then
          l_exact_tax_found := false;
      end;
    end if;

    -- Exact bank account match: same active-on-both-sides rule.
    if l_request.bank_account_fingerprint is not null then
      begin
        select fs.supplier_number, fs.supplier_name
          into l_exact_bank_supplier_number, l_exact_bank_supplier_name
          from fusion_supplier_bank_ref fbr
          join fusion_supplier_ref fs
            on fs.fusion_supplier_id = fbr.fusion_supplier_id
         where fbr.bank_account_fingerprint = l_request.bank_account_fingerprint
           and fbr.active = 'Y'
           and fs.active = 'Y'
           and rownum = 1;
        l_exact_bank_found := true;
      exception
        when no_data_found then
          l_exact_bank_found := false;
      end;
    end if;

    if l_exact_tax_found then
      l_tax_weight := supplier_config_pkg.risk_rule_weight('EXACT_TAX_ID_MATCH');
    end if;
    if l_exact_bank_found then
      l_bank_weight := supplier_config_pkg.risk_rule_weight('EXACT_BANK_MATCH');
    end if;

    if l_exact_tax_found or l_exact_bank_found then
      l_duplicate_level := 'EXACT';

      append_json_object(
        l_duplicate_json,
        l_duplicate_count,
        '{"match_type":"EXACT"' ||
        ',"tax_match":' || case when l_exact_tax_found then 'true' else 'false' end ||
        ',"bank_match":' || case when l_exact_bank_found then 'true' else 'false' end ||
        ',"fusion_supplier_name":"' || json_escape(coalesce(l_exact_tax_supplier_name, l_exact_bank_supplier_name)) || '"' ||
        ',"fusion_supplier_number":"' || json_escape(coalesce(l_exact_tax_supplier_number, l_exact_bank_supplier_number)) || '"}'
      );

      -- Design: "they are not added together" — use the single strongest
      -- exact indicator, never sum tax + bank.
      if l_tax_weight >= l_bank_weight then
        add_risk(
          l_risk_json, l_risk_count, 'EXACT_TAX_ID_MATCH', l_tax_weight, l_tax_weight,
          'Exact tax reference match on Fusion supplier ' || nvl(l_exact_tax_supplier_number, 'unknown'),
          l_duplicate_score
        );
      else
        add_risk(
          l_risk_json, l_risk_count, 'EXACT_BANK_MATCH', l_bank_weight, l_bank_weight,
          'Exact bank reference match on Fusion supplier ' || nvl(l_exact_bank_supplier_number, 'unknown'),
          l_duplicate_score
        );
      end if;
    else
      -- No exact match: fall back to weighted non-exact similarity,
      -- evaluated across every eligible active site candidate rather than
      -- a single aggregate MAX(), so we can identify which supplier/site
      -- actually produced the best score.
      find_best_similarity_candidate(
        p_request => l_request,
        p_best_score => l_sim_score,
        p_best_supplier_number => l_sim_supplier_number,
        p_best_supplier_name => l_sim_supplier_name,
        p_best_site_id => l_sim_site_id,
        p_best_name_similarity => l_sim_name_similarity,
        p_best_address_similarity => l_sim_address_similarity
      );

      if l_sim_score >= 85 then
        l_duplicate_score := supplier_config_pkg.risk_rule_weight('DUPLICATE_SIMILARITY');
        l_duplicate_level := 'STRONG';
      elsif l_sim_score >= 70 then
        l_duplicate_score := ceil(supplier_config_pkg.risk_rule_weight('DUPLICATE_SIMILARITY') / 2);
        l_duplicate_level := 'POSSIBLE';
      end if;

      if l_duplicate_score > 0 then
        l_rule_weight := supplier_config_pkg.risk_rule_weight('DUPLICATE_SIMILARITY');

        append_json_object(
          l_duplicate_json,
          l_duplicate_count,
          '{"match_type":"SIMILARITY"' ||
          ',"fusion_supplier_name":"' || json_escape(l_sim_supplier_name) || '"' ||
          ',"fusion_supplier_number":"' || json_escape(l_sim_supplier_number) || '"' ||
          ',"fusion_supplier_site_id":"' || json_escape(l_sim_site_id) || '"' ||
          ',"weighted_score":' || to_char(round(l_sim_score, 1)) ||
          ',"name_similarity":' || to_char(round(l_sim_name_similarity, 1)) ||
          ',"address_similarity":' || case when l_sim_address_similarity is null then 'null' else to_char(round(l_sim_address_similarity, 1)) end ||
          ',"duplicate_points":' || to_char(l_duplicate_score) || '}'
        );

        -- add_risk's p_score is an in-out accumulator; pass a fixed weight
        -- (l_rule_weight/l_duplicate_score, both independent of the
        -- accumulator itself) rather than reusing l_duplicate_score as both
        -- the applied weight and the score, which previously self-doubled it.
        add_risk(
          l_risk_json,
          l_risk_count,
          'DUPLICATE_SIMILARITY',
          l_rule_weight,
          l_duplicate_score,
          'Weighted similarity match (' || round(l_sim_score, 1) || ') against Fusion supplier ' || nvl(l_sim_supplier_number, 'unknown'),
          l_duplicate_score
        );
      end if;
    end if;

    declare
      l_max_base_weight number := supplier_config_pkg.risk_component_total('BASE');
    begin
      if l_max_base_weight > 0 then
        l_base_score := round((l_base_score / l_max_base_weight) * 100);
      else
        l_base_score := 0;
      end if;
    end;

    l_base_score := least(l_base_score, 100);
    l_duplicate_score := least(l_duplicate_score, 45);
    l_total_score := least(l_base_score + l_duplicate_score, 100);
    l_risk_level := supplier_projection_pkg.risk_level(l_total_score);

    l_validation_json := l_validation_json || ']';
    l_duplicate_json := l_duplicate_json || ']';
    l_risk_json := l_risk_json || ']';

    update request_assessment
       set is_latest = 'N'
     where request_id = p_request_id
       and is_latest = 'Y';

    insert into request_assessment (
      request_id,
      request_version,
      is_latest,
      validation_status,
      validation_results_json,
      duplicate_level,
      duplicate_matches_json,
      risk_score,
      risk_level,
      deterministic_risk_score,
      reviewer_adjustment_points,
      risk_factors_json,
      reference_sync_id,
      assessed_by_subject_id
    ) values (
      p_request_id,
      l_request.request_version,
      'Y',
      case when l_blocking_count > 0 then 'FAILED' when l_warning_count > 0 then 'WARNING' else 'PASSED' end,
      l_validation_json,
      l_duplicate_level,
      l_duplicate_json,
      l_total_score,
      l_risk_level,
      l_total_score,
      0,
      l_risk_json,
      'LOCAL_CACHE',
      p_actor_subject_id
    ) returning assessment_id into p_assessment_id;

    update supplier_request
       set risk_score = l_total_score,
           risk_level = l_risk_level,
           duplicate_level = l_duplicate_level,
           updated_at = systimestamp
     where request_id = p_request_id;
  end assess_request;
end supplier_validation_pkg;
/

create or replace package body supplier_workflow_pkg as
  function can_transition(
    p_from_status in varchar2,
    p_to_status in varchar2
  ) return varchar2 is
    l_pair varchar2(100);
  begin
    if p_from_status = p_to_status then
      return 'Y';
    end if;

    l_pair := upper(p_from_status) || '>' || upper(p_to_status);

    if l_pair in (
      'DRAFT>SUBMITTED',
      'SUBMITTED>VALIDATION_FAILED',
      'SUBMITTED>UNDER_REVIEW',
      'VALIDATION_FAILED>DRAFT',
      'VALIDATION_FAILED>SUBMITTED',
      'CORRECTION_REQUIRED>SUBMITTED',
      'UNDER_REVIEW>CORRECTION_REQUIRED',
      'UNDER_REVIEW>REJECTED',
      'UNDER_REVIEW>DUPLICATE',
      'UNDER_REVIEW>APPROVED',
      'APPROVED>SUBMITTED_TO_FUSION',
      'APPROVED>CREATED_IN_FUSION',
      'SUBMITTED_TO_FUSION>CREATED_IN_FUSION',
      'SUBMITTED_TO_FUSION>INTEGRATION_FAILED',
      'INTEGRATION_FAILED>SUBMITTED_TO_FUSION',
      'INTEGRATION_FAILED>CREATED_IN_FUSION'
    ) then
      return 'Y';
    end if;

    return 'N';
  end can_transition;

  procedure write_action(
    p_request_id in number,
    p_action in varchar2,
    p_from_status in varchar2,
    p_to_status in varchar2,
    p_actor_subject_id in varchar2,
    p_reason in varchar2 default null,
    p_existing_supplier_id in varchar2 default null
  ) is
  begin
    insert into action_history (
      request_id,
      action,
      from_status,
      to_status,
      reason,
      existing_supplier_id,
      actor_subject_id
    ) values (
      p_request_id,
      upper(p_action),
      p_from_status,
      p_to_status,
      p_reason,
      p_existing_supplier_id,
      p_actor_subject_id
    );
  end write_action;

  procedure transition_request(
    p_request_id in number,
    p_to_status in varchar2,
    p_action in varchar2,
    p_actor_subject_id in varchar2,
    p_reason in varchar2 default null,
    p_existing_supplier_id in varchar2 default null
  ) is
    l_from_status supplier_request.status%type;
  begin
    select status
      into l_from_status
      from supplier_request
     where request_id = p_request_id
     for update;

    if can_transition(l_from_status, p_to_status) <> 'Y' then
      raise_application_error(
        -20030,
        'Invalid request status transition from ' || l_from_status || ' to ' || p_to_status
      );
    end if;

    update supplier_request
       set status = p_to_status,
           submitted_at = case when p_to_status = 'SUBMITTED' then systimestamp else submitted_at end,
           reviewed_at = case
             when p_to_status in ('APPROVED', 'REJECTED', 'DUPLICATE', 'CORRECTION_REQUIRED') then systimestamp
             else reviewed_at
           end,
           updated_at = systimestamp
     where request_id = p_request_id;

    write_action(
      p_request_id => p_request_id,
      p_action => p_action,
      p_from_status => l_from_status,
      p_to_status => p_to_status,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => p_reason,
      p_existing_supplier_id => p_existing_supplier_id
    );
  end transition_request;
end supplier_workflow_pkg;
/

create or replace package body supplier_reference_pkg as

  -- Helper function to resolve country name / code to 2-letter ASCII ISO code
  function resolve_country_code(
    p_raw_country in varchar2,
    p_fallback    in varchar2 default 'US'
  ) return varchar2 is
    l_trimmed varchar2(100);
    l_clean   varchar2(10);
  begin
    l_trimmed := upper(trim(p_raw_country));
    
    if l_trimmed is null then
      if p_fallback is not null and length(trim(p_fallback)) = 2 and regexp_like(upper(trim(p_fallback)), '^[A-Z]{2}$') then
        return upper(trim(p_fallback));
      else
        return 'US';
      end if;
    end if;

    -- 1. If it's already a 2-letter ASCII code (e.g. 'US', 'PK', 'TR', 'MX', 'AD', 'BA')
    if length(l_trimmed) = 2 and regexp_like(l_trimmed, '^[A-Z]{2}$') then
      return l_trimmed;
    end if;

    -- 2. Common Country Names mapping
    case l_trimmed
      when 'UNITED STATES' then return 'US';
      when 'PAKISTAN' then return 'PK';
      when 'MEXICO' then return 'MX';
      when 'TURKEY' then return 'TR';
      when 'TÜRKIYE' then return 'TR';
      when 'TÜRKİYE' then return 'TR';
      when 'BOSNIA AND HERZEGOVINA' then return 'BA';
      when 'ANDORRA' then return 'AD';
      when 'ALBANIA' then return 'AL';
      when 'AMERICAN SAMOA' then return 'AS';
      when 'CANADA' then return 'CA';
      when 'UNITED KINGDOM' then return 'GB';
      when 'GERMANY' then return 'DE';
      when 'FRANCE' then return 'FR';
      when 'CHINA' then return 'CN';
      when 'INDIA' then return 'IN';
      when 'UNITED ARAB EMIRATES' then return 'AE';
      when 'SAUDI ARABIA' then return 'SA';
      else
        -- 3. Check if fallback matches 2 ASCII letters
        if p_fallback is not null and length(trim(p_fallback)) = 2 and regexp_like(upper(trim(p_fallback)), '^[A-Z]{2}$') then
          return upper(trim(p_fallback));
        end if;
        
        -- 4. Strip non-ASCII/special chars and take 2 letters
        l_clean := regexp_replace(l_trimmed, '[^A-Z]', '');
        if length(l_clean) >= 2 then
          return substr(l_clean, 1, 2);
        else
          return 'US';
        end if;
    end case;
  end resolve_country_code;

  procedure sync_batch(
    p_sync_id in varchar2 default null,
    p_payload in clob,
    p_status out varchar2,
    p_suppliers_synced out number,
    p_tax_synced out number,
    p_sites_synced out number,
    p_bank_synced out number,
    p_error_message out varchar2
  ) is
    l_sync_id          varchar2(120);
    l_root_tax_country varchar2(10);
    l_tx_country       varchar2(10);
    l_site_country     varchar2(10);
    l_bank_country     varchar2(10);
  begin
    p_status := 'SUCCESS';
    p_suppliers_synced := 0;
    p_tax_synced := 0;
    p_sites_synced := 0;
    p_bank_synced := 0;
    p_error_message := null;

    if p_payload is null or dbms_lob.getlength(p_payload) = 0 then
      p_status := 'EMPTY_PAYLOAD';
      return;
    end if;

    l_sync_id := coalesce(p_sync_id, json_value(p_payload, '$.syncId'), json_value(p_payload, '$.sync_id'), 'SYNC-' || to_char(systimestamp, 'YYYYMMDD-HH24MISS'));

    -- Process suppliers (supports both direct Fusion $.items[*] and custom $.suppliers[*])
    for sup in (
      select
        coalesce(fusion_supplier_id, to_char(fusion_id_num)) as fusion_supplier_id,
        coalesce(supplier_number, fusion_supplier_num, 'SUP-' || coalesce(fusion_supplier_id, to_char(fusion_id_num))) as supplier_number,
        coalesce(supplier_name, fusion_supplier_name) as supplier_name,
        coalesce(supplier_type, fusion_supplier_type, 'SUPPLIER') as supplier_type,
        case when upper(coalesce(active, status, 'Y')) in ('Y', 'TRUE', 'ACTIVE') then 'Y' else 'N' end as active,
        coalesce(tax_reg_num_root, taxpayer_id_root) as root_tax_num,
        tax_country_root,
        taxpayer_country_root,
        tax_org_type_root as root_tax_type,
        tax_registrations_json,
        addresses_json,
        sites_json,
        bank_accounts_json
      from json_table(
        p_payload,
        'lax $.items[*]'
        columns (
          fusion_supplier_id      varchar2(80)  path '$.fusionSupplierId',
          fusion_id_num           number        path '$.SupplierId',
          supplier_number         varchar2(80)  path '$.supplierNumber',
          fusion_supplier_num     varchar2(80)  path '$.SupplierNumber',
          supplier_name           varchar2(240) path '$.supplierName',
          fusion_supplier_name    varchar2(240) path '$.Supplier',
          supplier_type           varchar2(60)  path '$.supplierType',
          fusion_supplier_type    varchar2(60)  path '$.SupplierType',
          active                  varchar2(20)  path '$.active',
          status                  varchar2(20)  path '$.Status',
          tax_reg_num_root        varchar2(100) path '$.TaxRegistrationNumber',
          tax_country_root        varchar2(100) path '$.TaxRegistrationCountryCode',
          taxpayer_id_root        varchar2(100) path '$.TaxpayerId',
          taxpayer_country_root   varchar2(100) path '$.TaxpayerCountryCode',
          tax_org_type_root       varchar2(80)  path '$.TaxOrganizationType',
          tax_registrations_json  clob          format json path '$.taxRegistrations',
          addresses_json          clob          format json path '$.addresses',
          sites_json              clob          format json path '$.sites',
          bank_accounts_json      clob          format json path '$.bankAccounts'
        )
      )
      union all
      select
        coalesce(fusion_supplier_id, to_char(fusion_id_num)) as fusion_supplier_id,
        coalesce(supplier_number, fusion_supplier_num, 'SUP-' || coalesce(fusion_supplier_id, to_char(fusion_id_num))) as supplier_number,
        coalesce(supplier_name, fusion_supplier_name) as supplier_name,
        coalesce(supplier_type, fusion_supplier_type, 'SUPPLIER') as supplier_type,
        case when upper(coalesce(active, status, 'Y')) in ('Y', 'TRUE', 'ACTIVE') then 'Y' else 'N' end as active,
        coalesce(tax_reg_num_root, taxpayer_id_root) as root_tax_num,
        tax_country_root,
        taxpayer_country_root,
        tax_org_type_root as root_tax_type,
        tax_registrations_json,
        addresses_json,
        sites_json,
        bank_accounts_json
      from json_table(
        p_payload,
        'lax $.suppliers[*]'
        columns (
          fusion_supplier_id      varchar2(80)  path '$.fusionSupplierId',
          fusion_id_num           number        path '$.SupplierId',
          supplier_number         varchar2(80)  path '$.supplierNumber',
          fusion_supplier_num     varchar2(80)  path '$.SupplierNumber',
          supplier_name           varchar2(240) path '$.supplierName',
          fusion_supplier_name    varchar2(240) path '$.Supplier',
          supplier_type           varchar2(60)  path '$.supplierType',
          fusion_supplier_type    varchar2(60)  path '$.SupplierType',
          active                  varchar2(20)  path '$.active',
          status                  varchar2(20)  path '$.Status',
          tax_reg_num_root        varchar2(100) path '$.TaxRegistrationNumber',
          tax_country_root        varchar2(100) path '$.TaxRegistrationCountryCode',
          taxpayer_id_root        varchar2(100) path '$.TaxpayerId',
          taxpayer_country_root   varchar2(100) path '$.TaxpayerCountryCode',
          tax_org_type_root       varchar2(80)  path '$.TaxOrganizationType',
          tax_registrations_json  clob          format json path '$.taxRegistrations',
          addresses_json          clob          format json path '$.addresses',
          sites_json              clob          format json path '$.sites',
          bank_accounts_json      clob          format json path '$.bankAccounts'
        )
      )
    ) loop
      if sup.fusion_supplier_id is not null then
        l_root_tax_country := resolve_country_code(coalesce(sup.tax_country_root, sup.taxpayer_country_root), 'US');

        -- 1. Merge Supplier Header
        merge into fusion_supplier_ref t
        using (
          select
            sup.fusion_supplier_id as fusion_supplier_id,
            sup.supplier_number as supplier_number,
            sup.supplier_name as supplier_name,
            supplier_projection_pkg.normalize_text(sup.supplier_name) as supplier_name_normalized,
            sup.supplier_type as supplier_type,
            sup.active as active,
            l_sync_id as sync_id
          from dual
        ) s
        on (t.fusion_supplier_id = s.fusion_supplier_id)
        when matched then update set
          t.supplier_number          = s.supplier_number,
          t.supplier_name            = s.supplier_name,
          t.supplier_name_normalized = s.supplier_name_normalized,
          t.supplier_type            = s.supplier_type,
          t.active                   = s.active,
          t.last_seen_sync_id        = s.sync_id,
          t.last_synced_at           = systimestamp
        when not matched then insert (
          fusion_supplier_id, supplier_number, supplier_name,
          supplier_name_normalized, supplier_type, active,
          last_seen_sync_id, last_synced_at
        ) values (
          s.fusion_supplier_id, s.supplier_number, s.supplier_name,
          s.supplier_name_normalized, s.supplier_type, s.active,
          s.sync_id, systimestamp
        );
        p_suppliers_synced := p_suppliers_synced + 1;

        -- 2A. Merge Root Tax Registration
        if sup.root_tax_num is not null then
          merge into fusion_supplier_tax_ref t
          using (
            select
              'TAX-' || sup.fusion_supplier_id || '-ROOT' as fusion_tax_reference_id,
              sup.fusion_supplier_id as fusion_supplier_id,
              l_root_tax_country as country_code,
              coalesce(sup.root_tax_type, 'STANDARD') as tax_type,
              supplier_projection_pkg.fingerprint(sup.root_tax_num) as tax_id_fingerprint,
              supplier_projection_pkg.mask_identifier(sup.root_tax_num) as tax_id_masked,
              'Y' as active,
              l_sync_id as sync_id
            from dual
          ) s
          on (t.fusion_tax_reference_id = s.fusion_tax_reference_id)
          when matched then update set
            t.country_code       = s.country_code,
            t.tax_type           = s.tax_type,
            t.tax_id_fingerprint = s.tax_id_fingerprint,
            t.tax_id_masked      = s.tax_id_masked,
            t.active             = s.active,
            t.last_seen_sync_id  = s.sync_id,
            t.last_synced_at     = systimestamp
          when not matched then insert (
            fusion_tax_reference_id, fusion_supplier_id, country_code,
            tax_type, tax_id_fingerprint, tax_id_masked,
            active, last_seen_sync_id, last_synced_at
          ) values (
            s.fusion_tax_reference_id, s.fusion_supplier_id, s.country_code,
            s.tax_type, s.tax_id_fingerprint, s.tax_id_masked,
            s.active, s.sync_id, systimestamp
          );
          p_tax_synced := p_tax_synced + 1;
        end if;

        -- 2B. Merge Tax Registrations (Child array)
        if sup.tax_registrations_json is not null then
          for tx in (
            select
              coalesce(fusion_tax_ref_id, 'TAX-' || sup.fusion_supplier_id || '-' || rownum) as tax_ref_id,
              country_code_raw,
              coalesce(tax_type, 'STANDARD') as tax_type,
              tax_reg_num,
              case when upper(coalesce(active, 'Y')) in ('Y', 'TRUE') then 'Y' else 'N' end as active
            from json_table(
              sup.tax_registrations_json,
              '$[*]'
              columns (
                fusion_tax_ref_id varchar2(80)  path '$.fusionTaxReferenceId',
                country_code_raw  varchar2(100) path '$.countryCode',
                tax_type          varchar2(80)  path '$.taxType',
                tax_reg_num       varchar2(100) path '$.taxRegistrationNumber',
                active            varchar2(20)  path '$.active'
              )
            )
          ) loop
            l_tx_country := resolve_country_code(tx.country_code_raw, l_root_tax_country);
            if tx.tax_reg_num is not null and l_tx_country is not null then
              merge into fusion_supplier_tax_ref t
              using (
                select
                  tx.tax_ref_id as fusion_tax_reference_id,
                  sup.fusion_supplier_id as fusion_supplier_id,
                  l_tx_country as country_code,
                  tx.tax_type as tax_type,
                  supplier_projection_pkg.fingerprint(tx.tax_reg_num) as tax_id_fingerprint,
                  supplier_projection_pkg.mask_identifier(tx.tax_reg_num) as tax_id_masked,
                  tx.active as active,
                  l_sync_id as sync_id
                from dual
              ) s
              on (t.fusion_tax_reference_id = s.fusion_tax_reference_id)
              when matched then update set
                t.country_code       = s.country_code,
                t.tax_type           = s.tax_type,
                t.tax_id_fingerprint = s.tax_id_fingerprint,
                t.tax_id_masked      = s.tax_id_masked,
                t.active             = s.active,
                t.last_seen_sync_id  = s.sync_id,
                t.last_synced_at     = systimestamp
              when not matched then insert (
                fusion_tax_reference_id, fusion_supplier_id, country_code,
                tax_type, tax_id_fingerprint, tax_id_masked,
                active, last_seen_sync_id, last_synced_at
              ) values (
                s.fusion_tax_reference_id, s.fusion_supplier_id, s.country_code,
                s.tax_type, s.tax_id_fingerprint, s.tax_id_masked,
                s.active, s.sync_id, systimestamp
              );
              p_tax_synced := p_tax_synced + 1;
            end if;
          end loop;
        end if;

        -- 3A. Merge Addresses (Fusion format)
        if sup.addresses_json is not null then
          for addr in (
            select
              coalesce(to_char(address_id), 'ADDR-' || sup.fusion_supplier_id || '-' || rownum) as site_id,
              coalesce(address_name, 'Address ' || rownum) as site_name,
              country_raw,
              address_line1,
              address_line2,
              city,
              state_or_province,
              postal_code,
              email,
              phone,
              'Y' as active
            from json_table(
              sup.addresses_json,
              '$[*]'
              columns (
                address_id        number        path '$.AddressId',
                address_name      varchar2(200) path '$.AddressName',
                country_raw       varchar2(100) path '$.Country',
                address_line1     varchar2(240) path '$.AddressLine1',
                address_line2     varchar2(240) path '$.AddressLine2',
                city              varchar2(120) path '$.City',
                state_or_province varchar2(120) path '$.State',
                postal_code       varchar2(40)  path '$.PostalCode',
                email             varchar2(160) path '$.Email',
                phone             varchar2(80)  path '$.PhoneNumber'
              )
            )
          ) loop
            l_site_country := resolve_country_code(addr.country_raw, l_root_tax_country);
            if l_site_country is not null then
              merge into fusion_supplier_site_ref t
              using (
                select
                  addr.site_id as fusion_supplier_site_id,
                  sup.fusion_supplier_id as fusion_supplier_id,
                  addr.site_name as site_name,
                  addr.site_id as site_number,
                  l_site_country as country_code,
                  addr.address_line1 as address_line1,
                  addr.address_line2 as address_line2,
                  addr.city as city,
                  addr.state_or_province as state_or_province,
                  addr.postal_code as postal_code,
                  supplier_projection_pkg.normalize_text(addr.address_line1 || ' ' || addr.city || ' ' || l_site_country) as address_normalized,
                  case when instr(addr.email, '@') > 0 then lower(substr(addr.email, instr(addr.email, '@') + 1)) else null end as email_domain,
                  regexp_replace(addr.phone, '[^0-9]', '') as phone_normalized,
                  addr.active as active,
                  l_sync_id as sync_id
                from dual
              ) s
              on (t.fusion_supplier_site_id = s.fusion_supplier_site_id)
              when matched then update set
                t.site_name          = s.site_name,
                t.country_code       = s.country_code,
                t.address_line1      = s.address_line1,
                t.address_line2      = s.address_line2,
                t.city               = s.city,
                t.state_or_province  = s.state_or_province,
                t.postal_code        = s.postal_code,
                t.address_normalized = s.address_normalized,
                t.email_domain       = s.email_domain,
                t.phone_normalized   = s.phone_normalized,
                t.active             = s.active,
                t.last_seen_sync_id  = s.sync_id,
                t.last_synced_at     = systimestamp
              when not matched then insert (
                fusion_supplier_site_id, fusion_supplier_id, site_name,
                site_number, country_code, address_line1, address_line2,
                city, state_or_province, postal_code, address_normalized,
                email_domain, phone_normalized, active, last_seen_sync_id,
                last_synced_at
              ) values (
                s.fusion_supplier_site_id, s.fusion_supplier_id, s.site_name,
                s.site_number, s.country_code, s.address_line1, s.address_line2,
                s.city, s.state_or_province, s.postal_code, s.address_normalized,
                s.email_domain, s.phone_normalized, s.active, s.sync_id,
                systimestamp
              );
              p_sites_synced := p_sites_synced + 1;
            end if;
          end loop;
        end if;

        -- 3B. Merge Sites (Custom format)
        if sup.sites_json is not null then
          for st in (
            select
              coalesce(fusion_site_id, to_char(fusion_site_num), 'SITE-' || sup.fusion_supplier_id || '-' || rownum) as site_id,
              coalesce(site_name, fusion_site_name) as site_name,
              site_number,
              country_raw,
              address_line1,
              address_line2,
              city,
              state_or_province,
              postal_code,
              contact_email,
              phone,
              case when upper(coalesce(active, status, 'Y')) in ('Y', 'TRUE', 'ACTIVE') then 'Y' else 'N' end as active
            from json_table(
              sup.sites_json,
              '$[*]'
              columns (
                fusion_site_id    varchar2(80)  path '$.fusionSupplierSiteId',
                fusion_site_num   number        path '$.SupplierSiteId',
                site_name         varchar2(200) path '$.siteName',
                fusion_site_name  varchar2(200) path '$.SupplierSite',
                site_number       varchar2(80)  path '$.siteNumber',
                country_raw       varchar2(100) path '$.countryCode',
                address_line1     varchar2(240) path '$.addressLine1',
                address_line2     varchar2(240) path '$.addressLine2',
                city              varchar2(120) path '$.city',
                state_or_province varchar2(120) path '$.stateOrProvince',
                postal_code       varchar2(40)  path '$.postalCode',
                contact_email     varchar2(160) path '$.contactEmail',
                phone             varchar2(80)  path '$.phone',
                active            varchar2(20)  path '$.active',
                status            varchar2(20)  path '$.Status'
              )
            )
          ) loop
            l_site_country := resolve_country_code(st.country_raw, l_root_tax_country);
            if l_site_country is not null then
              merge into fusion_supplier_site_ref t
              using (
                select
                  st.site_id as fusion_supplier_site_id,
                  sup.fusion_supplier_id as fusion_supplier_id,
                  st.site_name as site_name,
                  st.site_number as site_number,
                  l_site_country as country_code,
                  st.address_line1 as address_line1,
                  st.address_line2 as address_line2,
                  st.city as city,
                  st.state_or_province as state_or_province,
                  st.postal_code as postal_code,
                  supplier_projection_pkg.normalize_text(st.address_line1 || ' ' || st.city || ' ' || l_site_country) as address_normalized,
                  case when instr(st.contact_email, '@') > 0 then lower(substr(st.contact_email, instr(st.contact_email, '@') + 1)) else null end as email_domain,
                  regexp_replace(st.phone, '[^0-9]', '') as phone_normalized,
                  st.active as active,
                  l_sync_id as sync_id
                from dual
              ) s
              on (t.fusion_supplier_site_id = s.fusion_supplier_site_id)
              when matched then update set
                t.site_name          = s.site_name,
                t.site_number        = s.site_number,
                t.country_code       = s.country_code,
                t.address_line1      = s.address_line1,
                t.address_line2      = s.address_line2,
                t.city               = s.city,
                t.state_or_province  = s.state_or_province,
                t.postal_code        = s.postal_code,
                t.address_normalized = s.address_normalized,
                t.email_domain       = s.email_domain,
                t.phone_normalized   = s.phone_normalized,
                t.active             = s.active,
                t.last_seen_sync_id  = s.sync_id,
                t.last_synced_at     = systimestamp
              when not matched then insert (
                fusion_supplier_site_id, fusion_supplier_id, site_name,
                site_number, country_code, address_line1, address_line2,
                city, state_or_province, postal_code, address_normalized,
                email_domain, phone_normalized, active, last_seen_sync_id,
                last_synced_at
              ) values (
                s.fusion_supplier_site_id, s.fusion_supplier_id, s.site_name,
                s.site_number, s.country_code, s.address_line1, s.address_line2,
                s.city, s.state_or_province, s.postal_code, s.address_normalized,
                s.email_domain, s.phone_normalized, s.active, s.sync_id,
                systimestamp
              );
              p_sites_synced := p_sites_synced + 1;
            end if;
          end loop;
        end if;

        -- 4. Bank Accounts
        if sup.bank_accounts_json is not null then
          for bk in (
            select
              coalesce(fusion_bank_id, 'BANK-' || sup.fusion_supplier_id || '-' || rownum) as bank_id,
              bank_country_code_raw,
              upper(substr(trim(currency_code), 1, 3)) as currency_code,
              bank_acc_num,
              case when upper(coalesce(active, 'Y')) in ('Y', 'TRUE') then 'Y' else 'N' end as active
            from json_table(
              sup.bank_accounts_json,
              '$[*]'
              columns (
                fusion_bank_id        varchar2(80)  path '$.fusionBankAccountId',
                bank_country_code_raw varchar2(100) path '$.bankCountryCode',
                currency_code         varchar2(10)  path '$.currencyCode',
                bank_acc_num          varchar2(100) path '$.bankAccountNumber',
                active                varchar2(20)  path '$.active'
              )
            )
          ) loop
            l_bank_country := resolve_country_code(bk.bank_country_code_raw, l_root_tax_country);
            if bk.bank_acc_num is not null then
              merge into fusion_supplier_bank_ref t
              using (
                select
                  bk.bank_id as fusion_bank_account_id,
                  sup.fusion_supplier_id as fusion_supplier_id,
                  l_bank_country as bank_country_code,
                  bk.currency_code as currency_code,
                  supplier_projection_pkg.fingerprint(bk.bank_acc_num) as bank_account_fingerprint,
                  substr(regexp_replace(bk.bank_acc_num, '[^0-9]', ''), -4) as bank_account_last_four,
                  bk.active as active,
                  l_sync_id as sync_id
                from dual
              ) s
              on (t.fusion_bank_account_id = s.fusion_bank_account_id)
              when matched then update set
                t.bank_country_code        = s.bank_country_code,
                t.currency_code            = s.currency_code,
                t.bank_account_fingerprint = s.bank_account_fingerprint,
                t.bank_account_last_four   = s.bank_account_last_four,
                t.active                   = s.active,
                t.last_seen_sync_id        = s.sync_id,
                t.last_synced_at           = systimestamp
              when not matched then insert (
                fusion_bank_account_id, fusion_supplier_id, bank_country_code,
                currency_code, bank_account_fingerprint, bank_account_last_four,
                active, last_seen_sync_id, last_synced_at
              ) values (
                s.fusion_bank_account_id, s.fusion_supplier_id, s.bank_country_code,
                s.currency_code, s.bank_account_fingerprint, s.bank_account_last_four,
                s.active, s.sync_id, systimestamp
              );
              p_bank_synced := p_bank_synced + 1;
            end if;
          end loop;
        end if;

      end if;
    end loop;

    commit;
    p_status := 'SUCCESS';
  exception
    when others then
      rollback;
      p_status := 'ERROR';
      p_error_message := sqlerrm;
  end sync_batch;
end supplier_reference_pkg;
/
