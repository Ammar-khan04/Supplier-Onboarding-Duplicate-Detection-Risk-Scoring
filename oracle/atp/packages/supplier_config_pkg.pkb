create or replace package body supplier_config_pkg as
  function get_number_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in number
  ) return number is
    l_value number;
  begin
    if p_config_type = 'RISK_RULE' and upper(p_value_name) in ('WEIGHT', 'WEIGHT_POINTS') then
      select weight_points
        into l_value
        from risk_rule_config
       where rule_code = upper(p_config_key)
         and active = 'Y';
    elsif p_config_type = 'RISK_SCORE_BAND' and upper(p_value_name) in ('MIN_SCORE', '$.MIN_SCORE') then
      select min_score
        into l_value
        from risk_score_band_config
       where risk_level = upper(p_config_key)
         and active = 'Y';
    elsif p_config_type = 'RISK_SCORE_BAND' and upper(p_value_name) in ('MAX_SCORE', '$.MAX_SCORE') then
      select max_score
        into l_value
        from risk_score_band_config
       where risk_level = upper(p_config_key)
         and active = 'Y';
    else
      select to_number(config_value)
        into l_value
        from configuration
       where config_type = p_config_type
         and config_key = p_config_key
         and active = 'Y';
    end if;

    return nvl(l_value, p_default_value);
  exception
    when no_data_found or value_error then
      return p_default_value;
  end get_number_value;

  function get_text_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in varchar2
  ) return varchar2 is
    l_value varchar2(4000);
  begin
    if p_config_type = 'TAX_REQUIREMENT' and upper(p_value_name) in ('REQUIRED', '$.REQUIRED') then
      return is_tax_required(p_config_key);
    elsif p_config_type = 'RISK_RULE' and upper(p_value_name) in ('COMPONENT', '$.COMPONENT') then
      select component
        into l_value
        from risk_rule_config
       where rule_code = upper(p_config_key)
         and active = 'Y';
    else
      select config_value
        into l_value
        from configuration
       where config_type = p_config_type
         and config_key = p_config_key
         and active = 'Y';
    end if;

    return nvl(l_value, p_default_value);
  exception
    when no_data_found then
      return p_default_value;
  end get_text_value;

  function risk_rule_weight(
    p_rule_code in varchar2
  ) return number is
    l_weight number;
  begin
    select weight_points
      into l_weight
      from risk_rule_config
     where rule_code = upper(p_rule_code)
       and active = 'Y';

    return l_weight;
  exception
    when no_data_found then
      return 0;
  end risk_rule_weight;

  function risk_component_total(
    p_component in varchar2
  ) return number is
    l_total number;
  begin
    select nvl(sum(weight_points), 0)
      into l_total
      from risk_rule_config
     where component = upper(p_component)
       and active = 'Y';

    return l_total;
  end risk_component_total;

  function is_high_risk_country(
    p_country_code in varchar2
  ) return varchar2 is
    l_count number;
  begin
    select count(*)
      into l_count
      from high_risk_country_config
     where country_code = upper(p_country_code)
       and active = 'Y';

    if l_count > 0 then
      return 'Y';
    end if;

    return 'N';
  end is_high_risk_country;

  function is_tax_required(
    p_country_code in varchar2,
    p_supplier_type in varchar2 default null
  ) return varchar2 is
    l_required char(1);
  begin
    select required
      into l_required
      from tax_requirement_config
     where country_code = upper(p_country_code)
       and active = 'Y'
       and supplier_type in (upper(nvl(p_supplier_type, 'ANY')), 'ANY')
     order by case when supplier_type = upper(nvl(p_supplier_type, 'ANY')) then 0 else 1 end
     fetch first 1 row only;

    return l_required;
  exception
    when no_data_found then
      return 'Y';
  end is_tax_required;

  procedure validate_risk_allocation is
    l_total number;
  begin
    select nvl(sum(weight_points), 0)
      into l_total
      from risk_rule_config
     where active = 'Y';

    if l_total <> 100 then
      raise_application_error(
        -20020,
        'Risk allocation is invalid: active risk rule weights must total exactly 100'
      );
    end if;
  end validate_risk_allocation;

  procedure update_risk_rule(
    p_actor_subject_id in varchar2,
    p_rule_code in varchar2,
    p_weight in number,
    p_active in varchar2 default 'Y'
  ) is
    l_rule_code varchar2(120);
    l_active char(1);
  begin
    l_rule_code := upper(trim(p_rule_code));
    l_active := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;

    if p_weight < 0 or p_weight > 100 then
      raise_application_error(-20021, 'Risk rule weight must be between 0 and 100');
    end if;

    update risk_rule_config
       set weight_points = p_weight,
           active = l_active,
           updated_by_subject_id = p_actor_subject_id,
           updated_at = systimestamp
     where rule_code = l_rule_code;

    if sql%rowcount = 0 then
      insert into risk_rule_config (
        rule_code,
        component,
        rule_name,
        condition_description,
        weight_points,
        active,
        display_order,
        updated_by_subject_id
      ) values (
        l_rule_code,
        'BASE',
        initcap(replace(lower(l_rule_code), '_', ' ')),
        'Admin maintained risk rule',
        p_weight,
        l_active,
        999,
        p_actor_subject_id
      );
    end if;

    validate_risk_allocation;
  end update_risk_rule;

  procedure set_high_risk_country(
    p_actor_subject_id in varchar2,
    p_country_code in varchar2,
    p_active in varchar2,
    p_reason in varchar2 default null,
    p_source in varchar2 default null
  ) is
    l_country_code varchar2(2);
    l_active char(1);
  begin
    l_country_code := upper(substr(trim(p_country_code), 1, 2));
    l_active := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;

    if not regexp_like(l_country_code, '^[A-Z]{2}$') then
      raise_application_error(-20022, 'Country code must be ISO alpha-2 format');
    end if;

    update high_risk_country_config
       set reason = nvl(p_reason, reason),
           source_name = nvl(p_source, source_name),
           active = l_active,
           updated_by_subject_id = p_actor_subject_id,
           updated_at = systimestamp
     where country_code = l_country_code;

    if sql%rowcount = 0 then
      insert into high_risk_country_config (
        country_code,
        reason,
        source_name,
        effective_date,
        active,
        updated_by_subject_id
      ) values (
        l_country_code,
        nvl(p_reason, 'Admin maintained high-risk country'),
        nvl(p_source, 'Admin'),
        trunc(current_date),
        l_active,
        p_actor_subject_id
      );
    end if;
  end set_high_risk_country;
end supplier_config_pkg;
/
