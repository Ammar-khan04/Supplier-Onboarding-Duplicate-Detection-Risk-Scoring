whenever sqlerror continue
alter session set container = FREEPDB1;
whenever sqlerror exit sql.sqlcode
alter session set current_schema = SUPPLIER_APP;

prompt Installing formal ATP seed data.
@/opt/supplier-atp/seed/001_seed_roles_permissions.sql
@/opt/supplier-atp/seed/002_seed_configuration.sql
@/opt/supplier-atp/seed/003_seed_supplier_reference_and_demo.sql

prompt Formal ATP seed data installed.
