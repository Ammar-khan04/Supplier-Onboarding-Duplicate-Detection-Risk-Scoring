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
    l_ai_count number;
    l_points number(5,2);
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REVIEWER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    l_points := nvl(p_points, -1);

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

    select count(*)
      into l_ai_count
      from ai_assessment
     where request_id = p_request_id
       and request_version = l_request_version
       and is_latest = 'Y'
       and status = 'SUCCEEDED';

    if l_ai_count = 0 then
      raise_application_error(-20054, 'A successful Gemini assessment is required before applying justification-risk points');
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
