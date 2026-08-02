create or replace package supplier_config_pkg as
  function get_number_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in number
  ) return number;

  function get_text_value(
    p_config_type in varchar2,
    p_config_key in varchar2,
    p_value_name in varchar2,
    p_default_value in varchar2
  ) return varchar2;

  function risk_rule_weight(
    p_rule_code in varchar2
  ) return number;

  function risk_component_total(
    p_component in varchar2
  ) return number;

  function is_high_risk_country(
    p_country_code in varchar2
  ) return varchar2;

  function is_tax_required(
    p_country_code in varchar2,
    p_supplier_type in varchar2 default null
  ) return varchar2;

  procedure validate_risk_allocation;

  procedure update_risk_rule(
    p_actor_subject_id in varchar2,
    p_rule_code in varchar2,
    p_weight in number,
    p_active in varchar2 default 'Y'
  );

  procedure set_high_risk_country(
    p_actor_subject_id in varchar2,
    p_country_code in varchar2,
    p_active in varchar2,
    p_reason in varchar2 default null,
    p_source in varchar2 default null
  );
end supplier_config_pkg;
/
