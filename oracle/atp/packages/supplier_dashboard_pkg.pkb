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
