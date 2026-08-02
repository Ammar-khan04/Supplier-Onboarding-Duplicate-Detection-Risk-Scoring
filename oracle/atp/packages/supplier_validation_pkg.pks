create or replace package supplier_validation_pkg as
  procedure assess_request(
    p_request_id in number,
    p_actor_subject_id in varchar2,
    p_assessment_id out number
  );
end supplier_validation_pkg;
/
