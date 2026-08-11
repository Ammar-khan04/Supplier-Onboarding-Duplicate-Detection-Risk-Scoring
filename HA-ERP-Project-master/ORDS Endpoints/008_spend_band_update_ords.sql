begin
  ords.define_template(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'spend-risk-bands/:band_name'
  );
  ords.define_handler(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'spend-risk-bands/:band_name',
    p_method      => 'PUT',
    p_source_type => ords.source_type_plsql,
    p_source      => q'[
      begin
        supplier_auth_pkg.require_role(coalesce(:actor_roles, 'ADMIN'), 'ADMIN');
        supplier_config_pkg.update_spend_risk_band(
          p_actor_subject_id => coalesce(:actor_subject_id, 'ADM_LINDA_SUB'),
          p_band_name => :band_name,
          p_min_amount => to_number(:min_amount),
          p_max_amount => to_number(:max_amount),
          p_risk_weight_percentage => to_number(:risk_weight_percentage),
          p_active => :active
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "spend_risk_band_updated"
}');
      end;
    ]'
  );
  commit;
end;
/
