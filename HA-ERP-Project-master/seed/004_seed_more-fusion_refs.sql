set define off
whenever sqlerror exit sql.sqlcode

prompt Seeding additional local Fusion reference cache for duplicate verification.

-- =========================================================================
-- Duplicate Test Case 1: Nova Office Supplies (Matches REQ-SEED-002)
-- =========================================================================

insert into fusion_supplier_ref (
  fusion_supplier_id,
  supplier_number,
  supplier_name,
  supplier_name_normalized,
  supplier_type,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'FUS-1002',
  'SUP-1002',
  'Nova Office Supplies',
  supplier_projection_pkg.normalize_text('Nova Office Supplies'),
  'COMPANY',
  'Y',
  systimestamp,
  'SYNC-SEED-002'
);

insert into fusion_supplier_tax_ref (
  fusion_tax_reference_id,
  fusion_supplier_id,
  country_code,
  tax_type,
  tax_id_fingerprint,
  tax_id_masked,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'TAX-1002',
  'FUS-1002',
  'US',
  'EIN',
  supplier_projection_pkg.fingerprint('US-EIN-11223344'),
  supplier_projection_pkg.mask_identifier('US-EIN-11223344'),
  'Y',
  systimestamp,
  'SYNC-SEED-002'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id,
  fusion_supplier_id,
  site_name,
  site_number,
  country_code,
  address_line1,
  city,
  address_normalized,
  email_domain,
  phone_normalized,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'SITE-1002',
  'FUS-1002',
  'Austin Main',
  'AUS-01',
  'US',
  '88 Market Street',
  'Austin',
  supplier_projection_pkg.normalize_text('88 Market Street Austin US'),
  'novaoffice.example',
  '15125550199',
  'Y',
  systimestamp,
  'SYNC-SEED-002'
);

insert into fusion_supplier_bank_ref (
  fusion_bank_account_id,
  fusion_supplier_id,
  bank_country_code,
  currency_code,
  bank_account_fingerprint,
  bank_account_last_four,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'BANK-1002',
  'FUS-1002',
  'US',
  'USD',
  supplier_projection_pkg.fingerprint('US-ACH-9876543210'),
  '3210',
  'Y',
  systimestamp,
  'SYNC-SEED-002'
);

-- =========================================================================
-- Duplicate Test Case 2: Cedar Logistics (Matches REQ-SEED-003)
-- =========================================================================

insert into fusion_supplier_ref (
  fusion_supplier_id,
  supplier_number,
  supplier_name,
  supplier_name_normalized,
  supplier_type,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'FUS-1003',
  'SUP-1003',
  'Cedar Logistics',
  supplier_projection_pkg.normalize_text('Cedar Logistics'),
  'COMPANY',
  'Y',
  systimestamp,
  'SYNC-SEED-003'
);

insert into fusion_supplier_tax_ref (
  fusion_tax_reference_id,
  fusion_supplier_id,
  country_code,
  tax_type,
  tax_id_fingerprint,
  tax_id_masked,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'TAX-1003',
  'FUS-1003',
  'AE',
  'VAT',
  supplier_projection_pkg.fingerprint('AE-TAX-9988'),
  supplier_projection_pkg.mask_identifier('AE-TAX-9988'),
  'Y',
  systimestamp,
  'SYNC-SEED-003'
);

insert into fusion_supplier_site_ref (
  fusion_supplier_site_id,
  fusion_supplier_id,
  site_name,
  site_number,
  country_code,
  address_line1,
  city,
  address_normalized,
  email_domain,
  phone_normalized,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'SITE-1003',
  'FUS-1003',
  'Dubai Port',
  'DXB-01',
  'AE',
  '21 Port Road',
  'Dubai',
  supplier_projection_pkg.normalize_text('21 Port Road Suite 3 Dubai AE'),
  'cedarlogistics.example',
  '97141234567',
  'Y',
  systimestamp,
  'SYNC-SEED-003'
);

insert into fusion_supplier_bank_ref (
  fusion_bank_account_id,
  fusion_supplier_id,
  bank_country_code,
  currency_code,
  bank_account_fingerprint,
  bank_account_last_four,
  active,
  source_last_updated_at,
  last_seen_sync_id
) values (
  'BANK-1003',
  'FUS-1003',
  'AE',
  'AED',
  supplier_projection_pkg.fingerprint('AE-IBAN-112233445566'),
  '5566',
  'Y',
  systimestamp,
  'SYNC-SEED-003'
);

commit;