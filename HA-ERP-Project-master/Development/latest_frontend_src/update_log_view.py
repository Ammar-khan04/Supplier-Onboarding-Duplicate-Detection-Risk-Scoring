import re

with open("../../Schemas/004_views_indexes.sql", "r") as f:
    sql = f.read()

target = """create or replace view integration_log_safe_v as
select
  job_id,
  parent_job_id,
  request_id,
  integration_type,
  status,
  attempt_number,
  oic_instance_id,
  payload_reference,
  response_reference,
  error_type,
  error_message,
  retryable,
  correlation_id,
  created_at,
  claimed_at,
  started_at,
  completed_at,
  updated_at
from integration_job;"""

new_view = """create or replace view integration_log_safe_v as
select
  j.job_id,
  j.parent_job_id,
  j.request_id,
  r.request_number,
  r.supplier_name,
  j.integration_type,
  j.status,
  j.attempt_number,
  j.oic_instance_id,
  j.payload_reference,
  j.response_reference,
  j.error_type,
  j.error_message,
  j.retryable,
  j.correlation_id,
  j.created_at,
  j.claimed_at,
  j.started_at,
  j.completed_at,
  j.updated_at
from integration_job j
left join supplier_request r on r.request_id = j.request_id;"""

sql = sql.replace(target, new_view)

with open("../../Schemas/004_views_indexes.sql", "w") as f:
    f.write(sql)

