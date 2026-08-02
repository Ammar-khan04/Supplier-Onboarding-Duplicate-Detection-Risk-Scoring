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
