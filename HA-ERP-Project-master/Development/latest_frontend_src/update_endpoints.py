import re

with open("../../ORDS Endpoints/001_supplier_onboarding_module.sql", "r") as f:
    sql = f.read()

# 1. Update GET /requests
req_target = """      select
        d.*,
        supplier_projection_pkg.allowed_actions(
          coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          coalesce(:actor_roles, 'REQUESTER'),
          d.request_id
        ) as allowed_actions
      from request_dashboard_v d
      where d.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
         or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
         or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN') = 'Y'
      order by d.updated_at desc
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only"""

req_new = """      select
        d.*,
        supplier_projection_pkg.allowed_actions(
          coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          coalesce(:actor_roles, 'REQUESTER'),
          d.request_id
        ) as allowed_actions
      from request_dashboard_v d
      where (d.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
         or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
         or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN') = 'Y')
         and (:status is null or d.status = :status)
         and (:search is null or upper(d.supplier_name) like '%' || upper(:search) || '%' or d.request_number = to_number(:search))
      order by
        case when lower(:sort_col) = 'status' and lower(:sort_dir) = 'asc' then d.status end asc,
        case when lower(:sort_col) = 'status' and lower(:sort_dir) = 'desc' then d.status end desc,
        case when lower(:sort_col) = 'supplier_name' and lower(:sort_dir) = 'asc' then d.supplier_name end asc,
        case when lower(:sort_col) = 'supplier_name' and lower(:sort_dir) = 'desc' then d.supplier_name end desc,
        case when lower(:sort_col) = 'request_number' and lower(:sort_dir) = 'asc' then d.request_number end asc,
        case when lower(:sort_col) = 'request_number' and lower(:sort_dir) = 'desc' then d.request_number end desc,
        case when lower(:sort_col) = 'risk_level' and lower(:sort_dir) = 'asc' then d.risk_level end asc,
        case when lower(:sort_col) = 'risk_level' and lower(:sort_dir) = 'desc' then d.risk_level end desc,
        case when lower(:sort_col) = 'duplicate_level' and lower(:sort_dir) = 'asc' then d.duplicate_level end asc,
        case when lower(:sort_col) = 'duplicate_level' and lower(:sort_dir) = 'desc' then d.duplicate_level end desc,
        d.updated_at desc
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only"""

if req_target in sql:
    sql = sql.replace(req_target, req_new)
else:
    print("Could not find target for GET /requests")


# 2. Update GET /integration-logs
log_target = """      select *
      from integration_log_safe_v
      where (:type is null or integration_type = upper(:type))
        and (:status is null or status = upper(:status))
      order by updated_at desc
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only"""

log_new = """      select *
      from integration_log_safe_v
      where (:type is null or integration_type = upper(:type))
        and (:status is null or status = upper(:status))
      order by
        case when lower(:sort_col) = 'status' and lower(:sort_dir) = 'asc' then status end asc,
        case when lower(:sort_col) = 'status' and lower(:sort_dir) = 'desc' then status end desc,
        case when lower(:sort_col) = 'supplier_name' and lower(:sort_dir) = 'asc' then supplier_name end asc,
        case when lower(:sort_col) = 'supplier_name' and lower(:sort_dir) = 'desc' then supplier_name end desc,
        case when lower(:sort_col) = 'request_number' and lower(:sort_dir) = 'asc' then request_number end asc,
        case when lower(:sort_col) = 'request_number' and lower(:sort_dir) = 'desc' then request_number end desc,
        case when lower(:sort_col) = 'integration_type' and lower(:sort_dir) = 'asc' then integration_type end asc,
        case when lower(:sort_col) = 'integration_type' and lower(:sort_dir) = 'desc' then integration_type end desc,
        case when lower(:sort_col) = 'oic_instance_id' and lower(:sort_dir) = 'asc' then oic_instance_id end asc,
        case when lower(:sort_col) = 'oic_instance_id' and lower(:sort_dir) = 'desc' then oic_instance_id end desc,
        updated_at desc
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only"""

if log_target in sql:
    sql = sql.replace(log_target, log_new)
else:
    print("Could not find target for GET /integration-logs")


# 3. Update GET /action-history
hist_target = """  select
    ah.*,
    r.request_number,
    r.supplier_name
  from action_history ah
  join supplier_request r on r.request_id = ah.request_id
  where (r.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
    or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
    or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN') = 'Y')
    and (:action_type is null or ah.action = upper(:action_type))
    order by ah.action_at desc
    offset nvl(to_number(:offset), 0) rows
    fetch next nvl(to_number(:limit), 200) rows only"""

hist_new = """  select
    ah.*,
    r.request_number,
    r.supplier_name
  from action_history ah
  join supplier_request r on r.request_id = ah.request_id
  where (r.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
    or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
    or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN') = 'Y')
    and (:action_type is null or ah.action = upper(:action_type))
    order by
        case when lower(:sort_col) = 'action' and lower(:sort_dir) = 'asc' then ah.action end asc,
        case when lower(:sort_col) = 'action' and lower(:sort_dir) = 'desc' then ah.action end desc,
        case when lower(:sort_col) = 'supplier_name' and lower(:sort_dir) = 'asc' then r.supplier_name end asc,
        case when lower(:sort_col) = 'supplier_name' and lower(:sort_dir) = 'desc' then r.supplier_name end desc,
        case when lower(:sort_col) = 'request_number' and lower(:sort_dir) = 'asc' then r.request_number end asc,
        case when lower(:sort_col) = 'request_number' and lower(:sort_dir) = 'desc' then r.request_number end desc,
        case when lower(:sort_col) = 'actor_subject_id' and lower(:sort_dir) = 'asc' then ah.actor_subject_id end asc,
        case when lower(:sort_col) = 'actor_subject_id' and lower(:sort_dir) = 'desc' then ah.actor_subject_id end desc,
        ah.action_at desc
    offset nvl(to_number(:offset), 0) rows
    fetch next nvl(to_number(:limit), 200) rows only"""

if hist_target in sql:
    sql = sql.replace(hist_target, hist_new)
else:
    print("Could not find target for GET /action-history")


with open("../../ORDS Endpoints/001_supplier_onboarding_module.sql", "w") as f:
    f.write(sql)
