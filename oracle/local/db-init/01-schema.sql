whenever sqlerror continue
alter session set container = FREEPDB1;
whenever sqlerror exit sql.sqlcode
alter session set current_schema = SUPPLIER_APP;

prompt Installing formal ATP schema scripts.
@/opt/supplier-atp/schema/001_core_request_schema.sql
@/opt/supplier-atp/schema/002_workflow_history_result_schema.sql
@/opt/supplier-atp/schema/003_configuration_schema.sql
@/opt/supplier-atp/schema/004_views_indexes.sql

prompt Installing PL/SQL package specifications.
@/opt/supplier-atp/packages/supplier_auth_pkg.pks
@/opt/supplier-atp/packages/supplier_workflow_pkg.pks
@/opt/supplier-atp/packages/supplier_config_pkg.pks
@/opt/supplier-atp/packages/supplier_validation_pkg.pks
@/opt/supplier-atp/packages/supplier_request_pkg.pks
@/opt/supplier-atp/packages/supplier_review_pkg.pks
@/opt/supplier-atp/packages/supplier_dashboard_pkg.pks
@/opt/supplier-atp/packages/supplier_integration_pkg.pks
@/opt/supplier-atp/packages/supplier_projection_pkg.pks

prompt Installing PL/SQL package bodies.
@/opt/supplier-atp/packages/supplier_auth_pkg.pkb
@/opt/supplier-atp/packages/supplier_config_pkg.pkb
@/opt/supplier-atp/packages/supplier_workflow_pkg.pkb
@/opt/supplier-atp/packages/supplier_projection_pkg.pkb
@/opt/supplier-atp/packages/supplier_validation_pkg.pkb
@/opt/supplier-atp/packages/supplier_request_pkg.pkb
@/opt/supplier-atp/packages/supplier_review_pkg.pkb
@/opt/supplier-atp/packages/supplier_dashboard_pkg.pkb
@/opt/supplier-atp/packages/supplier_integration_pkg.pkb

prompt Formal ATP schema and packages installed.
