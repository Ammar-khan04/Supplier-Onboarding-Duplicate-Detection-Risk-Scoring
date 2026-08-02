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
