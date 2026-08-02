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
      'SUBMITTED_TO_FUSION>CREATED_IN_FUSION',
      'SUBMITTED_TO_FUSION>INTEGRATION_FAILED',
      'INTEGRATION_FAILED>SUBMITTED_TO_FUSION'
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
