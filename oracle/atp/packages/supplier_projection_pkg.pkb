create or replace package body supplier_projection_pkg as
  function normalize_text(p_value in varchar2) return varchar2 is
  begin
    if p_value is null then
      return null;
    end if;

    return trim(regexp_replace(upper(p_value), '[^A-Z0-9]+', ' '));
  end normalize_text;

  function fingerprint(p_value in varchar2) return varchar2 is
    l_hash varchar2(128);
  begin
    if p_value is null then
      return null;
    end if;

    select rawtohex(standard_hash(normalize_text(p_value), 'SHA256'))
      into l_hash
      from dual;

    return l_hash;
  end fingerprint;

  function mask_identifier(p_value in varchar2) return varchar2 is
    l_clean varchar2(4000);
  begin
    if p_value is null then
      return null;
    end if;

    l_clean := regexp_replace(p_value, '[^[:alnum:]]', '');

    if length(l_clean) <= 4 then
      return '****' || l_clean;
    end if;

    return '****' || substr(l_clean, -4);
  end mask_identifier;

  function risk_level(p_score in number) return varchar2 is
    l_level varchar2(20);
  begin
    select risk_level
      into l_level
      from risk_score_band_config_v
     where active = 'Y'
       and p_score between min_score and max_score
     fetch first 1 row only;

    return l_level;
  exception
    when no_data_found then
      if p_score >= 70 then
        return 'CRITICAL';
      elsif p_score >= 40 then
        return 'HIGH';
      elsif p_score >= 20 then
        return 'MEDIUM';
      else
        return 'LOW';
      end if;
  end risk_level;

  function allowed_actions(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number
  ) return varchar2 is
    l_status supplier_request.status%type;
    l_requester supplier_request.requester_subject_id%type;
  begin
    select status, requester_subject_id
      into l_status, l_requester
      from supplier_request
     where request_id = p_request_id;

    if l_requester = p_actor_subject_id
       and l_status in ('DRAFT', 'VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      return '["EDIT","SUBMIT","UPLOAD_DOCUMENT"]';
    end if;

    if supplier_auth_pkg.has_role(p_actor_roles, 'REVIEWER') = 'Y'
       and l_status = 'UNDER_REVIEW' then
      return '["APPROVE","REJECT","REQUEST_CORRECTION","MARK_DUPLICATE","REGENERATE_AI","APPLY_JUSTIFICATION_RISK"]';
    end if;

    if supplier_auth_pkg.has_role(p_actor_roles, 'ADMIN') = 'Y'
       and l_status = 'INTEGRATION_FAILED' then
      return '["RETRY"]';
    end if;

    return '[]';
  exception
    when no_data_found then
      return '[]';
  end allowed_actions;
end supplier_projection_pkg;
/
