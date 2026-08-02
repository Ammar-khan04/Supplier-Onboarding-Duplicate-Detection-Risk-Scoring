create or replace package supplier_projection_pkg as
  function normalize_text(p_value in varchar2) return varchar2;
  function fingerprint(p_value in varchar2) return varchar2;
  function mask_identifier(p_value in varchar2) return varchar2;
  function risk_level(p_score in number) return varchar2;

  function allowed_actions(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number
  ) return varchar2;
end supplier_projection_pkg;
/
