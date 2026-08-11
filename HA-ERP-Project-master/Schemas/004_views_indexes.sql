set define off
whenever sqlerror exit sql.sqlcode

create unique index request_assessment_latest_uk
  on request_assessment (
    case when is_latest = 'Y' then request_id end
  );

create unique index request_document_latest_uk
  on request_document (
    case when is_latest = 'Y' then request_id end,
    case when is_latest = 'Y' then document_type end
  );

create unique index ai_assessment_latest_uk
  on ai_assessment (
    case when is_latest = 'Y' then request_id end,
    case when is_latest = 'Y' then request_version end
  );

create or replace view latest_request_assessment_v as
select *
from request_assessment
where is_latest = 'Y';

create or replace view request_dashboard_v as
select
  r.request_id,
  r.request_number,
  r.requester_subject_id,
  r.requester_display_name,
  r.status,
  r.request_version,
  r.supplier_name,
  r.supplier_type,
  r.country_code,
  r.business_unit,
  r.product_service_category,
  r.expected_annual_spend,
  r.currency_code,
  r.risk_score,
  r.risk_level,
  r.duplicate_level,
  r.fusion_supplier_number,
  r.created_at,
  r.updated_at,
  r.submitted_at,
  r.reviewed_at,
  a.validation_status,
  a.deterministic_risk_score,
  a.reviewer_adjustment_points,
  ai.justification_quality as latest_justification_quality,
  ai.status as latest_ai_status
from supplier_request r
left join latest_request_assessment_v a
  on a.request_id = r.request_id
left join ai_assessment ai
  on ai.request_id = r.request_id
 and ai.is_latest = 'Y';

create or replace view request_detail_safe_v as
select
  r.request_id,
  r.request_number,
  r.requester_subject_id,
  r.requester_display_name,
  r.requester_email,
  r.status,
  r.request_version,
  r.supplier_name,
  r.supplier_type,
  r.country_code,
  r.address_line1,
  r.address_line2,
  r.city,
  r.state_or_province,
  r.postal_code,
  r.contact_person,
  r.contact_email,
  r.contact_phone,
  r.business_unit,
  r.product_service_category,
  r.business_justification,
  r.expected_annual_spend,
  r.currency_code,
  r.base_currency_amount,
  r.base_currency_code,
  r.tax_registration_number,
  r.tax_registration_masked,
  r.bank_account_last_four,
  r.bank_country_code,
  r.bank_currency_code,
  r.site_name,
  r.site_address_line1,
  r.site_city,
  r.site_country_code,
  r.risk_score,
  r.risk_level,
  r.duplicate_level,
  r.fusion_supplier_id,
  r.fusion_supplier_number,
  r.fusion_create_error,
  r.created_at,
  r.updated_at,
  r.submitted_at,
  r.reviewed_at,
  a.validation_status,
  a.validation_results_json,
  a.duplicate_matches_json,
  a.risk_factors_json,
  a.deterministic_risk_score,
  a.reviewer_adjustment_points,
  a.reviewer_adjustment_reason,
  a.reviewer_adjusted_by_subject_id,
  a.reviewer_adjusted_at,
  a.reference_sync_id,
  ai.summary as latest_ai_summary,
  ai.recommended_actions as latest_ai_recommended_actions,
  ai.justification_quality as latest_justification_quality,
  ai.model_name as latest_ai_model_name,
  ai.status as latest_ai_status,
  (
    select reason
    from action_history
    where request_id = r.request_id
      and to_status = 'CORRECTION_REQUIRED'
    order by action_at desc
    fetch first 1 rows only
  ) as latest_correction_reason
from supplier_request r
left join latest_request_assessment_v a
  on a.request_id = r.request_id
left join ai_assessment ai
  on ai.request_id = r.request_id
 and ai.is_latest = 'Y';

create or replace view integration_log_safe_v as
select
  job_id,
  parent_job_id,
  request_id,
  integration_type,
  status,
  attempt_number,
  oic_instance_id,
  payload_reference,
  response_reference,
  error_type,
  error_message,
  retryable,
  correlation_id,
  created_at,
  claimed_at,
  started_at,
  completed_at,
  updated_at
from integration_job;

create or replace view risk_rule_config_v as
select
  rule_code,
  component,
  rule_name,
  condition_description,
  weight_points as weight,
  weight_points as max_weight,
  active,
  display_order,
  updated_by_subject_id,
  updated_at
from risk_rule_config;

create or replace view high_risk_country_config_v as
select
  country_code,
  reason,
  source_name,
  effective_date,
  active,
  updated_by_subject_id,
  updated_at
from high_risk_country_config;

create or replace view risk_score_band_config_v as
select
  risk_level,
  min_score,
  max_score,
  active,
  display_order,
  updated_by_subject_id,
  updated_at
from risk_score_band_config;

create or replace view request_document_v as
select
  document_id,
  request_id,
  request_version,
  document_type,
  file_name,
  mime_type,
  is_latest,
  uploaded_by_subject_id,
  uploaded_at,
  nvl(dbms_lob.getlength(document_content), 0) as file_size
from request_document;

create index supplier_request_status_ix on supplier_request (status, updated_at);
create index supplier_request_requester_ix on supplier_request (requester_subject_id, status, updated_at);
create index supplier_request_risk_ix on supplier_request (risk_level, risk_score, updated_at);
create index supplier_request_tax_fp_ix on supplier_request (tax_registration_fingerprint);
create index supplier_request_bank_fp_ix on supplier_request (bank_account_fingerprint);
create index request_assessment_req_ix on request_assessment (request_id, request_version, assessed_at);
create index action_history_req_ix on action_history (request_id, action_at);
create index integration_job_queue_ix on integration_job (integration_type, status, created_at);
create index integration_job_req_ix on integration_job (request_id, status, updated_at);
create index fusion_tax_fp_ix on fusion_supplier_tax_ref (tax_id_fingerprint, active);
create index fusion_bank_fp_ix on fusion_supplier_bank_ref (bank_account_fingerprint, active);
create index fusion_supplier_name_ix on fusion_supplier_ref (supplier_name_normalized, active);
create index fusion_site_match_ix on fusion_supplier_site_ref (fusion_supplier_id, country_code, active);
