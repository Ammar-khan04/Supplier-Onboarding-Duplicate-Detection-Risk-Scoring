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
