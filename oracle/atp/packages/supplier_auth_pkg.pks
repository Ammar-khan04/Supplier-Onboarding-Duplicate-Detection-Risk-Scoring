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
  