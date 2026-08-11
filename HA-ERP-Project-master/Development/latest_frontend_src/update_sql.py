import re

FILE = "/home/hussainsulaiman/Trainings/ERP Project/Project Files/ORDS Endpoints/001_supplier_onboarding_module.sql"

with open(FILE, "r") as f:
    sql = f.read()

# Replace risk_level ASC
sql = re.sub(
    r"case when lower\(:sort_col\) = 'risk_level' and lower\(:sort_dir\) = 'asc' then d\.risk_level end asc,",
    r"case when lower(:sort_col) = 'risk_level' and lower(:sort_dir) = 'asc' then case d.risk_level when 'CRITICAL' then 1 when 'HIGH' then 2 when 'MEDIUM' then 3 when 'LOW' then 4 else 5 end end asc,",
    sql
)
# Replace risk_level DESC
sql = re.sub(
    r"case when lower\(:sort_col\) = 'risk_level' and lower\(:sort_dir\) = 'desc' then d\.risk_level end desc,",
    r"case when lower(:sort_col) = 'risk_level' and lower(:sort_dir) = 'desc' then case d.risk_level when 'CRITICAL' then 1 when 'HIGH' then 2 when 'MEDIUM' then 3 when 'LOW' then 4 else 5 end end desc,",
    sql
)

# Replace duplicate_level ASC
sql = re.sub(
    r"case when lower\(:sort_col\) = 'duplicate_level' and lower\(:sort_dir\) = 'asc' then d\.duplicate_level end asc,",
    r"case when lower(:sort_col) = 'duplicate_level' and lower(:sort_dir) = 'asc' then case d.duplicate_level when 'EXACT' then 1 when 'STRONG' then 2 when 'POSSIBLE' then 3 when 'NONE' then 4 else 5 end end asc,",
    sql
)
# Replace duplicate_level DESC
sql = re.sub(
    r"case when lower\(:sort_col\) = 'duplicate_level' and lower\(:sort_dir\) = 'desc' then d\.duplicate_level end desc,",
    r"case when lower(:sort_col) = 'duplicate_level' and lower(:sort_dir) = 'desc' then case d.duplicate_level when 'EXACT' then 1 when 'STRONG' then 2 when 'POSSIBLE' then 3 when 'NONE' then 4 else 5 end end desc,",
    sql
)

with open(FILE, "w") as f:
    f.write(sql)
