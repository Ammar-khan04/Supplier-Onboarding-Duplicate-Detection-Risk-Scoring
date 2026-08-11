import re

with open("../../Schemas/004_views_indexes.sql", "r") as f:
    sql = f.read()

# Add latest_correction_reason to the view
old_columns = """  ai.model_name as latest_ai_model_name,
  ai.status as latest_ai_status
from supplier_request r"""

new_columns = """  ai.model_name as latest_ai_model_name,
  ai.status as latest_ai_status,
  (
    select reason
    from action_history
    where request_id = r.request_id
      and to_status = 'CORRECTION_REQUIRED'
    order by action_at desc
    fetch first 1 rows only
  ) as latest_correction_reason
from supplier_request r"""

sql = sql.replace(old_columns, new_columns)

with open("../../Schemas/004_views_indexes.sql", "w") as f:
    f.write(sql)
