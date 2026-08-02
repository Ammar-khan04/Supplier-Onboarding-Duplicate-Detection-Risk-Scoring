set define off
whenever sqlerror exit sql.sqlcode

prompt Seeding finalized risk, threshold, tax, and routing configuration.

insert into risk_rule_config values (
  'MISSING_TAX_ID',
  'BASE',
  'Missing tax registration',
  'Tax registration is missing where applicable',
  10,
  'Y',
  10,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'MISSING_BANK_DETAILS',
  'BASE',
  'Missing bank details',
  'Bank information is not available yet',
  5,
  'Y',
  20,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'BANK_COUNTRY_MISMATCH',
  'BASE',
  'Bank country mismatch',
  'Bank country differs from supplier country',
  10,
  'Y',
  30,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'HIGH_RISK_COUNTRY',
  'BASE',
  'High-risk country',
  'Supplier country is on the Admin-maintained high-risk list',
  15,
  'Y',
  40,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'INCOMPLETE_ADDRESS',
  'BASE',
  'Incomplete address',
  'Address quality fields are incomplete',
  5,
  'Y',
  50,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'MISSING_EXPECTED_DOCUMENT',
  'BASE',
  'Missing expected document',
  'Expected supporting document is missing',
  5,
  'Y',
  60,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'HIGH_EXPECTED_SPEND',
  'BASE',
  'High expected spend',
  'Expected annual spend falls in the configured band',
  5,
  'Y',
  70,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'EXACT_TAX_ID_MATCH',
  'DUPLICATE',
  'Exact tax match',
  'Exact tax fingerprint match in local Fusion cache',
  20,
  'Y',
  80,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'EXACT_BANK_MATCH',
  'DUPLICATE',
  'Exact bank match',
  'Exact bank fingerprint match in local Fusion cache',
  15,
  'Y',
  90,
  'SYSTEM',
  systimestamp
);

insert into risk_rule_config values (
  'DUPLICATE_SIMILARITY',
  'DUPLICATE',
  'Duplicate similarity',
  'Fuzzy supplier similarity contribution',
  10,
  'Y',
  100,
  'SYSTEM',
  systimestamp
);

insert into risk_score_band_config values ('LOW', 0, 24, 'Y', 10, 'SYSTEM', systimestamp);
insert into risk_score_band_config values ('MEDIUM', 25, 49, 'Y', 20, 'SYSTEM', systimestamp);
insert into risk_score_band_config values ('HIGH', 50, 74, 'Y', 30, 'SYSTEM', systimestamp);
insert into risk_score_band_config values ('CRITICAL', 75, 100, 'Y', 40, 'SYSTEM', systimestamp);

insert into high_risk_country_config values (
  'IR',
  'Seeded sanctions and enhanced review list',
  'Prototype baseline',
  date '2026-07-21',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into high_risk_country_config values (
  'KP',
  'Seeded sanctions and enhanced review list',
  'Prototype baseline',
  date '2026-07-21',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into high_risk_country_config values (
  'SY',
  'Seeded sanctions and enhanced review list',
  'Prototype baseline',
  date '2026-07-21',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into tax_requirement_config values (
  'PK',
  'ANY',
  'Y',
  'Prototype assumes tax registration is applicable',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into tax_requirement_config values (
  'US',
  'ANY',
  'Y',
  'Prototype assumes tax registration is applicable',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into tax_requirement_config values (
  'AE',
  'ANY',
  'Y',
  'Prototype assumes tax registration is applicable',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into business_unit_site_mapping values (
  'PROCUREMENT',
  'Procurement Intake',
  'PK',
  'Y',
  'SYSTEM',
  systimestamp
);

insert into generic_justification_phrase values (
  'LOW_DETAIL',
  'needed for business',
  'WARNING',
  'Y',
  'SYSTEM',
  systimestamp
);

begin
  supplier_config_pkg.validate_risk_allocation;
end;
/

commit;
