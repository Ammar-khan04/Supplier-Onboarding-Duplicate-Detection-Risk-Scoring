begin
  -- Currency Exchange Rates GET endpoint
  ords.define_template(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'currency-exchange-rates'
  );
  ords.define_handler(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'currency-exchange-rates',
    p_method      => 'GET',
    p_source_type => ords.source_type_collection_feed,
    p_source      => q'[
      select
        currency_code,
        to_usd_rate,
        active,
        updated_by_subject_id,
        updated_at
      from currency_exchange_rate
      order by currency_code asc
    ]'
  );

  -- Spend Risk Bands GET endpoint
  ords.define_template(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'spend-risk-bands'
  );
  ords.define_handler(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'spend-risk-bands',
    p_method      => 'GET',
    p_source_type => ords.source_type_collection_feed,
    p_source      => q'[
      select
        band_name,
        min_amount,
        max_amount,
        risk_weight_percentage,
        active,
        updated_by_subject_id,
        updated_at
      from spend_risk_band_config
      order by min_amount asc
    ]'
  );
  
  commit;
end;
/
