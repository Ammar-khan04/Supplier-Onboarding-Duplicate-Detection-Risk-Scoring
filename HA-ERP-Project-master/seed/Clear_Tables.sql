-- 1. Clear child tables of integration_job and supplier_request
DELETE FROM integration_job;
DELETE FROM action_history;
DELETE FROM ai_assessment;
DELETE FROM request_assessment;
DELETE FROM request_document;

-- 2. Clear the main supplier_request parent table
DELETE FROM supplier_request;

-- 3. Clear child tables of the Fusion reference cache
DELETE FROM fusion_supplier_bank_ref;
DELETE FROM fusion_supplier_site_ref;
DELETE FROM fusion_supplier_tax_ref;

-- 4. Clear the main fusion_supplier_ref parent table
DELETE FROM fusion_supplier_ref;

-- 5. Clear all configuration tables
DELETE FROM generic_justification_phrase;
DELETE FROM business_unit_site_mapping;
DELETE FROM tax_requirement_config;
DELETE FROM high_risk_country_config;
DELETE FROM risk_score_band_config;
DELETE FROM risk_rule_config;
DELETE FROM configuration;