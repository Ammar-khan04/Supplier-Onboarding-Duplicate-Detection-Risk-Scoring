whenever sqlerror exit sql.sqlcode
set define off

begin
  ords.enable_schema(
    p_enabled => true,
    p_schema => 'SUPPLIER_APP',
    p_url_mapping_type => 'BASE_PATH',
    p_url_mapping_pattern => 'supplier-onboarding',
    p_auto_rest_auth => false
  );
  commit;
end;
/

prompt Installing formal ORDS supplier onboarding module.
@/opt/supplier-ords/modules/001_supplier_onboarding_module.sql

prompt Formal ORDS module installed.
