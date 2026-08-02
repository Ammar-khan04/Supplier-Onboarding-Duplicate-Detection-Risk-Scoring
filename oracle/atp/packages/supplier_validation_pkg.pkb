create or replace package body supplier_validation_pkg as
  procedure append_json_object(
    p_json in out nocopy clob,
    p_count in out number,
    p_object in varchar2
  ) is
  begin
    if p_count > 0 then
      p_json := p_json || ',';
    end if;

    p_json := p_json || p_object;
    p_count := p_count + 1;
  end append_json_object;

  procedure add_risk(
    p_json in out nocopy clob,
    p_count in out number,
    p_rule_code in varchar2,
    p_configured_weight in number,
    p_applied_weight in number,
    p_evidence in varchar2,
    p_score in out number
  ) is
  begin
    if p_applied_weight <= 0 then
      return;
    end if;

    append_json_object(
      p_json,
      p_count,
      '{"rule_code":"' || p_rule_code ||
      '","configured_weight":' || to_char(p_configured_weight) ||
      ',"applied_weight":' || to_char(p_applied_weight) ||
      ',"evidence":"' || replace(p_evidence, '"', '''') || '"}'
    );

    p_score := p_score + p_applied_weight;
  end add_risk;

  procedure assess_request(
    p_request_id in number,
    p_actor_subject_id in varchar2,
    p_assessment_id out number
  ) is
    l_request supplier_request%rowtype;
    l_validation_json clob := '[';
    l_duplicate_json clob := '[';
    l_risk_json clob := '[';
    l_validation_count number := 0;
    l_duplicate_count number := 0;
    l_risk_count number := 0;
    l_blocking_count number := 0;
    l_warning_count number := 0;
    l_base_score number := 0;
    l_duplicate_score number := 0;
    l_total_score number := 0;
    l_risk_level varchar2(20);
    l_duplicate_level varchar2(20) := 'NONE';
    l_tax_required varchar2(20);
    l_missing_quality number := 0;
    l_address_weight number;
    l_spend_weight number := 0;
    l_exact_tax_count number := 0;
    l_exact_bank_count number := 0;
    l_similarity number := 0;
    l_doc_count number := 0;
    l_rule_weight number;
  begin
    select *
      into l_request
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_request.supplier_name is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"supplier_name","severity":"ERROR","blocking":true,"message":"Supplier name is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.country_code is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"country_code","severity":"ERROR","blocking":true,"message":"Country is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.supplier_type is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"supplier_type","severity":"ERROR","blocking":true,"message":"Supplier type is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.business_unit is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"business_unit","severity":"ERROR","blocking":true,"message":"Business unit is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if l_request.address_line1 is null or l_request.city is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"address","severity":"ERROR","blocking":true,"message":"Address line 1 and city are required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    if not regexp_like(nvl(l_request.contact_email, 'missing'), '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$') then
      append_json_object(l_validation_json, l_validation_count, '{"field":"contact_email","severity":"ERROR","blocking":true,"message":"Valid contact email is required"}');
      l_blocking_count := l_blocking_count + 1;
    end if;

    l_tax_required := supplier_config_pkg.is_tax_required(l_request.country_code, l_request.supplier_type);

    if upper(l_tax_required) = 'Y' and l_request.tax_registration_number is null then
      append_json_object(l_validation_json, l_validation_count, '{"field":"tax_registration_number","severity":"ERROR","blocking":true,"message":"Tax registration number is required where applicable"}');
      l_blocking_count := l_blocking_count + 1;
      l_rule_weight := supplier_config_pkg.risk_rule_weight('MISSING_TAX_ID');
      add_risk(l_risk_json, l_risk_count, 'MISSING_TAX_ID', l_rule_weight, l_rule_weight, 'Applicable tax registration is missing', l_base_score);
    end if;

    if l_request.bank_account_fingerprint is null then
      l_rule_weight := supplier_config_pkg.risk_rule_weight('MISSING_BANK_DETAILS');
      add_risk(l_risk_json, l_risk_count, 'MISSING_BANK_DETAILS', l_rule_weight, l_rule_weight, 'Bank details are not yet available', l_base_score);
    elsif l_request.bank_country_code is not null and l_request.bank_country_code <> l_request.country_code then
      append_json_object(l_validation_json, l_validation_count, '{"field":"bank_country_code","severity":"WARNING","blocking":false,"message":"Bank country differs from supplier country"}');
      l_warning_count := l_warning_count + 1;
      l_rule_weight := supplier_config_pkg.risk_rule_weight('BANK_COUNTRY_MISMATCH');
      add_risk(l_risk_json, l_risk_count, 'BANK_COUNTRY_MISMATCH', l_rule_weight, l_rule_weight, 'Bank country differs from supplier country', l_base_score);
    end if;

    if supplier_config_pkg.is_high_risk_country(l_request.country_code) = 'Y' then
      l_rule_weight := supplier_config_pkg.risk_rule_weight('HIGH_RISK_COUNTRY');
      add_risk(l_risk_json, l_risk_count, 'HIGH_RISK_COUNTRY', l_rule_weight, l_rule_weight, 'Supplier country is on the Admin-maintained high-risk list', l_base_score);
    end if;

    if l_request.address_line2 is null then
      l_missing_quality := l_missing_quality + 1;
    end if;
    if l_request.postal_code is null then
      l_missing_quality := l_missing_quality + 1;
    end if;
    if l_request.contact_phone is null then
      l_missing_quality := l_missing_quality + 1;
    end if;

    if l_missing_quality > 0 then
      l_address_weight := ceil(supplier_config_pkg.risk_rule_weight('INCOMPLETE_ADDRESS') * l_missing_quality / 3);
      add_risk(
        l_risk_json,
        l_risk_count,
        'INCOMPLETE_ADDRESS',
        supplier_config_pkg.risk_rule_weight('INCOMPLETE_ADDRESS'),
        l_address_weight,
        'Address quality fields are incomplete',
        l_base_score
      );
    end if;

    select count(*)
      into l_doc_count
      from request_document
     where request_id = p_request_id
       and is_latest = 'Y';

    if l_doc_count = 0 then
      l_rule_weight := supplier_config_pkg.risk_rule_weight('MISSING_EXPECTED_DOCUMENT');
      add_risk(l_risk_json, l_risk_count, 'MISSING_EXPECTED_DOCUMENT', l_rule_weight, l_rule_weight, 'No supporting document is attached', l_base_score);
    end if;

    if nvl(l_request.base_currency_amount, l_request.expected_annual_spend) >= 500000 then
      l_spend_weight := 5;
    elsif nvl(l_request.base_currency_amount, l_request.expected_annual_spend) >= 250000 then
      l_spend_weight := 3;
    elsif nvl(l_request.base_currency_amount, l_request.expected_annual_spend) >= 100000 then
      l_spend_weight := 2;
    end if;

    add_risk(
      l_risk_json,
      l_risk_count,
      'HIGH_EXPECTED_SPEND',
      supplier_config_pkg.risk_rule_weight('HIGH_EXPECTED_SPEND'),
      l_spend_weight,
      'Expected annual spend falls in the configured band',
      l_base_score
    );

    if l_request.tax_registration_fingerprint is not null then
      select count(*)
        into l_exact_tax_count
        from fusion_supplier_tax_ref
       where tax_id_fingerprint = l_request.tax_registration_fingerprint
         and active = 'Y';
    end if;

    if l_request.bank_account_fingerprint is not null then
      select count(*)
        into l_exact_bank_count
        from fusion_supplier_bank_ref
       where bank_account_fingerprint = l_request.bank_account_fingerprint
         and active = 'Y';
    end if;

    if l_exact_tax_count > 0 or l_exact_bank_count > 0 then
      l_duplicate_level := 'EXACT';
      append_json_object(
        l_duplicate_json,
        l_duplicate_count,
        '{"match_type":"EXACT","tax_match_count":' ||
        to_char(l_exact_tax_count) || ',"bank_match_count":' || to_char(l_exact_bank_count) || '}'
      );

      if l_exact_tax_count > 0 then
        l_rule_weight := supplier_config_pkg.risk_rule_weight('EXACT_TAX_ID_MATCH');
        add_risk(
          l_risk_json,
          l_risk_count,
          'EXACT_TAX_ID_MATCH',
          l_rule_weight,
          l_rule_weight,
          'Exact tax reference match found in local Fusion cache',
          l_duplicate_score
        );
      end if;

      if l_exact_bank_count > 0 then
        l_rule_weight := supplier_config_pkg.risk_rule_weight('EXACT_BANK_MATCH');
        add_risk(
          l_risk_json,
          l_risk_count,
          'EXACT_BANK_MATCH',
          l_rule_weight,
          l_rule_weight,
          'Exact bank reference match found in local Fusion cache',
          l_duplicate_score
        );
      end if;
    else
      begin
        select max(utl_match.jaro_winkler_similarity(l_request.supplier_name_normalized, fs.supplier_name_normalized))
          into l_similarity
          from fusion_supplier_ref fs
          join fusion_supplier_site_ref fss
            on fss.fusion_supplier_id = fs.fusion_supplier_id
         where fs.active = 'Y'
           and fss.active = 'Y'
           and fss.country_code = l_request.country_code;
      exception
        when others then
          l_similarity := 0;
      end;

      if l_similarity >= 85 then
        l_duplicate_score := supplier_config_pkg.risk_rule_weight('DUPLICATE_SIMILARITY');
        l_duplicate_level := 'STRONG';
      elsif l_similarity >= 70 then
        l_duplicate_score := ceil(supplier_config_pkg.risk_rule_weight('DUPLICATE_SIMILARITY') / 2);
        l_duplicate_level := 'POSSIBLE';
      end if;

      if l_duplicate_score > 0 then
        l_rule_weight := supplier_config_pkg.risk_rule_weight('DUPLICATE_SIMILARITY');
        append_json_object(
          l_duplicate_json,
          l_duplicate_count,
          '{"match_type":"SIMILARITY","similarity_score":' || to_char(l_similarity) ||
          ',"duplicate_points":' || to_char(l_duplicate_score) || '}'
        );
        add_risk(
          l_risk_json,
          l_risk_count,
          'DUPLICATE_SIMILARITY',
          l_rule_weight,
          l_duplicate_score,
          'Supplier name and country are similar to local Fusion reference data',
          l_duplicate_score
        );
        l_duplicate_score := case when l_similarity >= 85 then l_rule_weight else ceil(l_rule_weight / 2) end;
      end if;
    end if;

    l_base_score := least(l_base_score, supplier_config_pkg.risk_component_total('BASE'));
    l_duplicate_score := least(l_duplicate_score, supplier_config_pkg.risk_component_total('DUPLICATE'));
    l_total_score := least(l_base_score + l_duplicate_score, 100);
    l_risk_level := supplier_projection_pkg.risk_level(l_total_score);

    l_validation_json := l_validation_json || ']';
    l_duplicate_json := l_duplicate_json || ']';
    l_risk_json := l_risk_json || ']';

    update request_assessment
       set is_latest = 'N'
     where request_id = p_request_id
       and is_latest = 'Y';

    insert into request_assessment (
      request_id,
      request_version,
      is_latest,
      validation_status,
      validation_results_json,
      duplicate_level,
      duplicate_matches_json,
      risk_score,
      risk_level,
      deterministic_risk_score,
      reviewer_adjustment_points,
      risk_factors_json,
      reference_sync_id,
      assessed_by_subject_id
    ) values (
      p_request_id,
      l_request.request_version,
      'Y',
      case when l_blocking_count > 0 then 'FAILED' when l_warning_count > 0 then 'WARNING' else 'PASSED' end,
      l_validation_json,
      l_duplicate_level,
      l_duplicate_json,
      l_total_score,
      l_risk_level,
      l_total_score,
      0,
      l_risk_json,
      'LOCAL_CACHE',
      p_actor_subject_id
    ) returning assessment_id into p_assessment_id;

    update supplier_request
       set risk_score = l_total_score,
           risk_level = l_risk_level,
           duplicate_level = l_duplicate_level,
           updated_at = systimestamp
     where request_id = p_request_id;
  end assess_request;
end supplier_validation_pkg;
/
