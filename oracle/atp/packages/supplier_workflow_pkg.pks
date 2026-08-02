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
