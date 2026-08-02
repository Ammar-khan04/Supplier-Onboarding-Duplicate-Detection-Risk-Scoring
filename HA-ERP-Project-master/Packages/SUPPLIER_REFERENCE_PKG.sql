-- =============================================================================
-- Session 4: supplier_reference_pkg
-- Extends supplier-reference/batch to populate all four Fusion reference tables:
--   FUSION_SUPPLIER_REF (header)
--   FUSION_SUPPLIER_TAX_REF
--   FUSION_SUPPLIER_SITE_REF
--   FUSION_SUPPLIER_BANK_REF
--
-- Design rules implemented:
--   - Tax ID: normalize -> SHA-256 fingerprint (same as supplier_projection_pkg.fingerprint)
--   - Bank: normalize (strip non-alnum) -> SHA-256 fingerprint, retain last four
--   - Site: normalize address components -> address_normalized; extract email_domain;
--           strip non-digits -> phone_normalized
--   - Incremental sync: omitted child rows are NOT deactivated (only deactivate when
--     Fusion explicitly marks active=false in the payload, or on a full-snapshot sync
--     where the row is absent and p_full_snapshot=true)
--   - Returns sync_id, header/tax/site/bank upsert counts, and rejected record count
-- =============================================================================

set define off
whenever sqlerror exit sql.sqlcode

-- ---------------------------------------------------------------------------
-- Package spec
-- ---------------------------------------------------------------------------
create or replace package supplier_reference_pkg as

  -- Upsert a single supplier header plus its child tax, site, and bank rows.
  -- Called once per supplier element in the batch.
  procedure upsert_supplier(
    p_sync_id              in varchar2,
    p_fusion_supplier_id   in varchar2,
    p_supplier_number      in varchar2,
    p_supplier_name        in varchar2,
    p_supplier_type        in varchar2 default null,
    p_active               in varchar2 default 'Y',
    p_source_updated_at    in varchar2 default null,  -- ISO 8601 string
    p_tax_json             in clob     default null,  -- JSON array of tax rows
    p_site_json            in clob     default null,  -- JSON array of site rows
    p_bank_json            in clob     default null,  -- JSON array of bank rows
    p_full_snapshot        in varchar2 default 'N',   -- 'Y' = deactivate absent children
    p_rejected_count       in out number
  );

  -- Process the full batch payload (JSON string from the ORDS handler).
  -- Returns upsert counts for each table and total rejected records.
  procedure process_batch(
    p_payload_json         in clob,
    p_sync_id              out varchar2,
    p_header_upsert_count  out number,
    p_tax_upsert_count     out number,
    p_site_upsert_count    out number,
    p_bank_upsert_count    out number,
    p_rejected_count       out number
  );

end supplier_reference_pkg;
/

-- ---------------------------------------------------------------------------
-- Package body
-- ---------------------------------------------------------------------------
create or replace package body supplier_reference_pkg as

  -- -------------------------------------------------------------------------
  -- Internal: normalize a phone number to digits only. Returns null if result
  -- is empty (e.g. the input was a placeholder like 'N/A').
  -- -------------------------------------------------------------------------
  function normalize_phone(p_value in varchar2) return varchar2 is
    l_result varchar2(40);
  begin
    if p_value is null then
      return null;
    end if;
    l_result := regexp_replace(p_value, '[^0-9]', '');
    if length(l_result) = 0 then
      return null;
    end if;
    return l_result;
  end normalize_phone;

  -- -------------------------------------------------------------------------
  -- Internal: extract the domain portion from an email address.
  -- Returns null if the value has no '@' or is null.
  -- -------------------------------------------------------------------------
  function extract_email_domain(p_email in varchar2) return varchar2 is
    l_at number;
  begin
    if p_email is null then
      return null;
    end if;
    l_at := instr(p_email, '@');
    if l_at = 0 then
      return null;
    end if;
    return lower(substr(p_email, l_at + 1));
  end extract_email_domain;

  -- -------------------------------------------------------------------------
  -- Internal: parse an ISO 8601 string into a TIMESTAMP WITH LOCAL TIME ZONE.
  -- Returns null on any parse failure so a bad date never blocks the upsert.
  -- -------------------------------------------------------------------------
  function parse_iso_ts(p_value in varchar2) return timestamp with local time zone is
    l_ts timestamp with local time zone;
  begin
    if p_value is null then
      return null;
    end if;
    -- Try with fractional seconds first, then plain seconds
    begin
      l_ts := to_timestamp_tz(p_value, 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM');
    exception
      when others then
        begin
          l_ts := to_timestamp_tz(p_value, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM');
        exception
          when others then
            return null;
        end;
    end;
    return l_ts;
  end parse_iso_ts;

  -- -------------------------------------------------------------------------
  -- Internal: upsert one tax reference row.
  -- -------------------------------------------------------------------------
  procedure upsert_tax_row(
    p_sync_id            in varchar2,
    p_fusion_supplier_id in varchar2,
    p_tax_ref_id         in varchar2,
    p_country_code       in varchar2,
    p_tax_type           in varchar2,
    p_tax_number_raw     in varchar2,
    p_active             in varchar2,
    p_source_updated_at  in varchar2
  ) is
    l_fingerprint varchar2(128);
    l_masked      varchar2(120);
    l_active      char(1);
    l_ts          timestamp with local time zone;
  begin
    l_active      := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;
    l_fingerprint := supplier_projection_pkg.fingerprint(p_tax_number_raw);
    l_masked      := supplier_projection_pkg.mask_identifier(p_tax_number_raw);
    l_ts          := parse_iso_ts(p_source_updated_at);

    merge into fusion_supplier_tax_ref t
    using (
      select
        p_tax_ref_id         as fusion_tax_reference_id,
        p_fusion_supplier_id as fusion_supplier_id,
        upper(substr(trim(p_country_code), 1, 2)) as country_code,
        upper(trim(p_tax_type))                   as tax_type,
        l_fingerprint                              as tax_id_fingerprint,
        l_masked                                   as tax_id_masked,
        l_active                                   as active,
        l_ts                                       as source_last_updated_at,
        p_sync_id                                  as sync_id
      from dual
    ) s
    on (t.fusion_tax_reference_id = s.fusion_tax_reference_id)
    when matched then update set
      t.country_code          = s.country_code,
      t.tax_type              = s.tax_type,
      t.tax_id_fingerprint    = s.tax_id_fingerprint,
      t.tax_id_masked         = s.tax_id_masked,
      t.active                = s.active,
      t.source_last_updated_at = nvl(s.source_last_updated_at, t.source_last_updated_at),
      t.last_seen_sync_id     = s.sync_id,
      t.last_synced_at        = systimestamp
    when not matched then insert (
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
      s.fusion_tax_reference_id,
      s.fusion_supplier_id,
      s.country_code,
      s.tax_type,
      s.tax_id_fingerprint,
      s.tax_id_masked,
      s.active,
      s.source_last_updated_at,
      s.sync_id
    );
  end upsert_tax_row;

  -- -------------------------------------------------------------------------
  -- Internal: upsert one site reference row.
  -- -------------------------------------------------------------------------
  procedure upsert_site_row(
    p_sync_id            in varchar2,
    p_fusion_supplier_id in varchar2,
    p_site_id            in varchar2,
    p_site_name          in varchar2,
    p_site_number        in varchar2,
    p_country_code       in varchar2,
    p_address_line1      in varchar2,
    p_address_line2      in varchar2,
    p_city               in varchar2,
    p_state_or_province  in varchar2,
    p_postal_code        in varchar2,
    p_contact_email      in varchar2,
    p_phone              in varchar2,
    p_active             in varchar2,
    p_source_updated_at  in varchar2
  ) is
    l_country         char(2);
    l_addr_normalized varchar2(1000);
    l_email_domain    varchar2(160);
    l_phone_normalized varchar2(80);
    l_active          char(1);
    l_ts              timestamp with local time zone;
  begin
    l_country          := upper(substr(trim(p_country_code), 1, 2));
    l_active           := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;
    l_ts               := parse_iso_ts(p_source_updated_at);
    l_email_domain     := extract_email_domain(p_contact_email);
    l_phone_normalized := normalize_phone(p_phone);

    -- Normalize address the same way supplier_request_pkg does for requests,
    -- so Jaro-Winkler comparisons are on a consistent normalized form.
    l_addr_normalized := supplier_projection_pkg.normalize_text(
      nvl(p_address_line1, '') || ' ' ||
      nvl(p_city, '') || ' ' ||
      nvl(p_country_code, '')
    );

    merge into fusion_supplier_site_ref t
    using (
      select
        p_site_id            as fusion_supplier_site_id,
        p_fusion_supplier_id as fusion_supplier_id,
        p_site_name          as site_name,
        p_site_number        as site_number,
        l_country            as country_code,
        p_address_line1      as address_line1,
        p_address_line2      as address_line2,
        p_city               as city,
        p_state_or_province  as state_or_province,
        p_postal_code        as postal_code,
        l_addr_normalized    as address_normalized,
        l_email_domain       as email_domain,
        l_phone_normalized   as phone_normalized,
        l_active             as active,
        l_ts                 as source_last_updated_at,
        p_sync_id            as sync_id
      from dual
    ) s
    on (t.fusion_supplier_site_id = s.fusion_supplier_site_id)
    when matched then update set
      t.site_name              = s.site_name,
      t.site_number            = s.site_number,
      t.country_code           = s.country_code,
      t.address_line1          = s.address_line1,
      t.address_line2          = s.address_line2,
      t.city                   = s.city,
      t.state_or_province      = s.state_or_province,
      t.postal_code            = s.postal_code,
      t.address_normalized     = s.address_normalized,
      t.email_domain           = s.email_domain,
      t.phone_normalized       = s.phone_normalized,
      t.active                 = s.active,
      t.source_last_updated_at = nvl(s.source_last_updated_at, t.source_last_updated_at),
      t.last_seen_sync_id      = s.sync_id,
      t.last_synced_at         = systimestamp
    when not matched then insert (
      fusion_supplier_site_id,
      fusion_supplier_id,
      site_name,
      site_number,
      country_code,
      address_line1,
      address_line2,
      city,
      state_or_province,
      postal_code,
      address_normalized,
      email_domain,
      phone_normalized,
      active,
      source_last_updated_at,
      last_seen_sync_id
    ) values (
      s.fusion_supplier_site_id,
      s.fusion_supplier_id,
      s.site_name,
      s.site_number,
      s.country_code,
      s.address_line1,
      s.address_line2,
      s.city,
      s.state_or_province,
      s.postal_code,
      s.address_normalized,
      s.email_domain,
      s.phone_normalized,
      s.active,
      s.source_last_updated_at,
      s.sync_id
    );
  end upsert_site_row;

  -- -------------------------------------------------------------------------
  -- Internal: upsert one bank reference row.
  -- Raw account number is NOT stored. Only the fingerprint and last-four are kept.
  -- -------------------------------------------------------------------------
  procedure upsert_bank_row(
    p_sync_id            in varchar2,
    p_fusion_supplier_id in varchar2,
    p_bank_account_id    in varchar2,
    p_bank_country_code  in varchar2,
    p_currency_code      in varchar2,
    p_account_number_raw in varchar2,
    p_active             in varchar2,
    p_source_updated_at  in varchar2
  ) is
    l_fingerprint  varchar2(128);
    l_last_four    varchar2(4);
    l_active       char(1);
    l_ts           timestamp with local time zone;
    l_clean_number varchar2(4000);
  begin
    l_active := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;
    l_ts     := parse_iso_ts(p_source_updated_at);

    -- Normalize: strip all non-alnum chars for fingerprint and last-four.
    -- This mirrors what supplier_request_pkg does for request bank values.
    l_clean_number := regexp_replace(p_account_number_raw, '[^[:alnum:]]', '');
    l_fingerprint  := supplier_projection_pkg.fingerprint(l_clean_number);
    l_last_four    := case
                        when length(l_clean_number) >= 4
                        then substr(l_clean_number, -4)
                        else l_clean_number
                      end;

    merge into fusion_supplier_bank_ref t
    using (
      select
        p_bank_account_id    as fusion_bank_account_id,
        p_fusion_supplier_id as fusion_supplier_id,
        upper(substr(trim(p_bank_country_code), 1, 2)) as bank_country_code,
        upper(substr(trim(p_currency_code), 1, 3))     as currency_code,
        l_fingerprint                                   as bank_account_fingerprint,
        l_last_four                                     as bank_account_last_four,
        l_active                                        as active,
        l_ts                                            as source_last_updated_at,
        p_sync_id                                       as sync_id
      from dual
    ) s
    on (t.fusion_bank_account_id = s.fusion_bank_account_id)
    when matched then update set
      t.bank_country_code      = s.bank_country_code,
      t.currency_code          = s.currency_code,
      t.bank_account_fingerprint = s.bank_account_fingerprint,
      t.bank_account_last_four   = s.bank_account_last_four,
      t.active                   = s.active,
      t.source_last_updated_at   = nvl(s.source_last_updated_at, t.source_last_updated_at),
      t.last_seen_sync_id        = s.sync_id,
      t.last_synced_at           = systimestamp
    when not matched then insert (
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
      s.fusion_bank_account_id,
      s.fusion_supplier_id,
      s.bank_country_code,
      s.currency_code,
      s.bank_account_fingerprint,
      s.bank_account_last_four,
      s.active,
      s.source_last_updated_at,
      s.sync_id
    );
  end upsert_bank_row;

  -- -------------------------------------------------------------------------
  -- Public: upsert one supplier header + child rows.
  -- JSON child arrays are iterated with json_table. Any row that errors is
  -- counted in p_rejected_count and skipped — it never rolls back the header
  -- or other child rows for this supplier.
  -- -------------------------------------------------------------------------
  procedure upsert_supplier(
    p_sync_id              in varchar2,
    p_fusion_supplier_id   in varchar2,
    p_supplier_number      in varchar2,
    p_supplier_name        in varchar2,
    p_supplier_type        in varchar2 default null,
    p_active               in varchar2 default 'Y',
    p_source_updated_at    in varchar2 default null,
    p_tax_json             in clob     default null,
    p_site_json            in clob     default null,
    p_bank_json            in clob     default null,
    p_full_snapshot        in varchar2 default 'N',
    p_rejected_count       in out number
  ) is
    l_active  char(1);
    l_ts      timestamp with local time zone;
    l_sync_id varchar2(120);
  begin
    l_active  := case when upper(nvl(p_active, 'Y')) = 'Y' then 'Y' else 'N' end;
    l_ts      := parse_iso_ts(p_source_updated_at);
    l_sync_id := nvl(p_sync_id, 'MANUAL_SYNC');

    -- 1. Header upsert (FUSION_SUPPLIER_REF)
    merge into fusion_supplier_ref t
    using (
      select
        p_fusion_supplier_id as fusion_supplier_id,
        p_supplier_number    as supplier_number,
        p_supplier_name      as supplier_name,
        supplier_projection_pkg.normalize_text(p_supplier_name) as supplier_name_normalized,
        upper(trim(p_supplier_type)) as supplier_type,
        l_active             as active,
        l_ts                 as source_last_updated_at,
        l_sync_id            as sync_id
      from dual
    ) s
    on (t.fusion_supplier_id = s.fusion_supplier_id)
    when matched then update set
      t.supplier_number          = s.supplier_number,
      t.supplier_name            = s.supplier_name,
      t.supplier_name_normalized = s.supplier_name_normalized,
      t.supplier_type            = nvl(s.supplier_type, t.supplier_type),
      t.active                   = s.active,
      t.source_last_updated_at   = nvl(s.source_last_updated_at, t.source_last_updated_at),
      t.last_seen_sync_id        = s.sync_id,
      t.last_synced_at           = systimestamp
    when not matched then insert (
      fusion_supplier_id,
      supplier_number,
      supplier_name,
      supplier_name_normalized,
      supplier_type,
      active,
      source_last_updated_at,
      last_seen_sync_id
    ) values (
      s.fusion_supplier_id,
      s.supplier_number,
      s.supplier_name,
      s.supplier_name_normalized,
      s.supplier_type,
      s.active,
      s.source_last_updated_at,
      s.sync_id
    );

    -- 2. Tax rows
    if p_tax_json is not null and length(p_tax_json) > 2 then
      for r in (
        select
          jt.fusion_tax_reference_id,
          jt.country_code,
          jt.tax_type,
          jt.tax_registration_number,
          jt.active,
          jt.source_last_updated_at
        from json_table(
          p_tax_json, '$[*]'
          columns (
            fusion_tax_reference_id    varchar2(80)   path '$.fusionTaxReferenceId',
            country_code               varchar2(2)    path '$.countryCode',
            tax_type                   varchar2(80)   path '$.taxType',
            tax_registration_number    varchar2(240)  path '$.taxRegistrationNumber',
            active                     varchar2(10)   path '$.active',
            source_last_updated_at     varchar2(40)   path '$.sourceLastUpdatedAt'
          )
        ) jt
        where jt.fusion_tax_reference_id is not null
          and jt.tax_registration_number is not null
      ) loop
        begin
          upsert_tax_row(
            p_sync_id            => l_sync_id,
            p_fusion_supplier_id => p_fusion_supplier_id,
            p_tax_ref_id         => r.fusion_tax_reference_id,
            p_country_code       => r.country_code,
            p_tax_type           => r.tax_type,
            p_tax_number_raw     => r.tax_registration_number,
            p_active             => r.active,
            p_source_updated_at  => r.source_last_updated_at
          );
        exception
          when others then
            p_rejected_count := p_rejected_count + 1;
        end;
      end loop;

      -- Full-snapshot deactivation: mark absent tax rows inactive for this supplier.
      if upper(nvl(p_full_snapshot, 'N')) = 'Y' then
        update fusion_supplier_tax_ref
           set active = 'N',
               last_synced_at = systimestamp
         where fusion_supplier_id = p_fusion_supplier_id
           and last_seen_sync_id <> l_sync_id
           and active = 'Y';
      end if;
    end if;

    -- 3. Site rows
    if p_site_json is not null and length(p_site_json) > 2 then
      for r in (
        select
          jt.fusion_supplier_site_id,
          jt.site_name,
          jt.site_number,
          jt.country_code,
          jt.address_line1,
          jt.address_line2,
          jt.city,
          jt.state_or_province,
          jt.postal_code,
          jt.contact_email,
          jt.phone,
          jt.active,
          jt.source_last_updated_at
        from json_table(
          p_site_json, '$[*]'
          columns (
            fusion_supplier_site_id  varchar2(80)   path '$.fusionSupplierSiteId',
            site_name                varchar2(200)  path '$.siteName',
            site_number              varchar2(80)   path '$.siteNumber',
            country_code             varchar2(2)    path '$.countryCode',
            address_line1            varchar2(240)  path '$.addressLine1',
            address_line2            varchar2(240)  path '$.addressLine2',
            city                     varchar2(120)  path '$.city',
            state_or_province        varchar2(120)  path '$.stateOrProvince',
            postal_code              varchar2(40)   path '$.postalCode',
            contact_email            varchar2(240)  path '$.contactEmail',
            phone                    varchar2(60)   path '$.phone',
            active                   varchar2(10)   path '$.active',
            source_last_updated_at   varchar2(40)   path '$.sourceLastUpdatedAt'
          )
        ) jt
        where jt.fusion_supplier_site_id is not null
          and jt.country_code is not null
      ) loop
        begin
          upsert_site_row(
            p_sync_id            => l_sync_id,
            p_fusion_supplier_id => p_fusion_supplier_id,
            p_site_id            => r.fusion_supplier_site_id,
            p_site_name          => r.site_name,
            p_site_number        => r.site_number,
            p_country_code       => r.country_code,
            p_address_line1      => r.address_line1,
            p_address_line2      => r.address_line2,
            p_city               => r.city,
            p_state_or_province  => r.state_or_province,
            p_postal_code        => r.postal_code,
            p_contact_email      => r.contact_email,
            p_phone              => r.phone,
            p_active             => r.active,
            p_source_updated_at  => r.source_last_updated_at
          );
        exception
          when others then
            p_rejected_count := p_rejected_count + 1;
        end;
      end loop;

      if upper(nvl(p_full_snapshot, 'N')) = 'Y' then
        update fusion_supplier_site_ref
           set active = 'N',
               last_synced_at = systimestamp
         where fusion_supplier_id = p_fusion_supplier_id
           and last_seen_sync_id <> l_sync_id
           and active = 'Y';
      end if;
    end if;

    -- 4. Bank rows
    if p_bank_json is not null and length(p_bank_json) > 2 then
      for r in (
        select
          jt.fusion_bank_account_id,
          jt.bank_country_code,
          jt.currency_code,
          jt.bank_account_number,
          jt.active,
          jt.source_last_updated_at
        from json_table(
          p_bank_json, '$[*]'
          columns (
            fusion_bank_account_id  varchar2(80)   path '$.fusionBankAccountId',
            bank_country_code       varchar2(2)    path '$.bankCountryCode',
            currency_code           varchar2(3)    path '$.currencyCode',
            bank_account_number     varchar2(240)  path '$.bankAccountNumber',
            active                  varchar2(10)   path '$.active',
            source_last_updated_at  varchar2(40)   path '$.sourceLastUpdatedAt'
          )
        ) jt
        where jt.fusion_bank_account_id is not null
          and jt.bank_account_number is not null
      ) loop
        begin
          upsert_bank_row(
            p_sync_id            => l_sync_id,
            p_fusion_supplier_id => p_fusion_supplier_id,
            p_bank_account_id    => r.fusion_bank_account_id,
            p_bank_country_code  => r.bank_country_code,
            p_currency_code      => r.currency_code,
            p_account_number_raw => r.bank_account_number,
            p_active             => r.active,
            p_source_updated_at  => r.source_last_updated_at
          );
        exception
          when others then
            p_rejected_count := p_rejected_count + 1;
        end;
      end loop;

      if upper(nvl(p_full_snapshot, 'N')) = 'Y' then
        update fusion_supplier_bank_ref
           set active = 'N',
               last_synced_at = systimestamp
         where fusion_supplier_id = p_fusion_supplier_id
           and last_seen_sync_id <> l_sync_id
           and active = 'Y';
      end if;
    end if;

  end upsert_supplier;

  -- -------------------------------------------------------------------------
  -- Public: process a full batch payload.
  -- Expected payload shape (matches design doc and ORDS handler):
  -- {
  --   "syncId": "SYNC-20260716-01",
  --   "fullSnapshot": false,          -- optional, defaults to false
  --   "suppliers": [ { ... }, ... ]
  -- }
  -- -------------------------------------------------------------------------
  procedure process_batch(
    p_payload_json         in clob,
    p_sync_id              out varchar2,
    p_header_upsert_count  out number,
    p_tax_upsert_count     out number,
    p_site_upsert_count    out number,
    p_bank_upsert_count    out number,
    p_rejected_count       out number
  ) is
    l_sync_id       varchar2(120);
    l_full_snapshot varchar2(10);
    l_rejected      number := 0;
    l_header_before number;
    l_tax_before    number;
    l_site_before   number;
    l_bank_before   number;
    l_header_after  number;
    l_tax_after     number;
    l_site_after    number;
    l_bank_after    number;
  begin
    p_header_upsert_count := 0;
    p_tax_upsert_count    := 0;
    p_site_upsert_count   := 0;
    p_bank_upsert_count   := 0;
    p_rejected_count      := 0;

    -- Extract top-level syncId and fullSnapshot flag
    select
      nvl(jt.sync_id, 'SYNC-' || to_char(systimestamp, 'YYYYMMDD-HH24MISS')),
      nvl(jt.full_snapshot, 'false')
    into l_sync_id, l_full_snapshot
    from json_table(
      p_payload_json, '$'
      columns (
        sync_id       varchar2(120) path '$.syncId',
        full_snapshot varchar2(10)  path '$.fullSnapshot'
      )
    ) jt;

    p_sync_id := l_sync_id;

    -- Snapshot row counts before processing (used to compute upsert deltas)
    select count(*) into l_header_before from fusion_supplier_ref;
    select count(*) into l_tax_before    from fusion_supplier_tax_ref;
    select count(*) into l_site_before   from fusion_supplier_site_ref;
    select count(*) into l_bank_before   from fusion_supplier_bank_ref;

    -- Iterate supplier array
    for s in (
      select
        jt.fusion_supplier_id,
        jt.supplier_number,
        jt.supplier_name,
        jt.supplier_type,
        jt.active,
        jt.source_last_updated_at,
        jt.tax_registrations,
        jt.sites,
        jt.bank_accounts
      from json_table(
        p_payload_json, '$.suppliers[*]'
        columns (
          fusion_supplier_id     varchar2(80)   path '$.fusionSupplierId',
          supplier_number        varchar2(80)   path '$.supplierNumber',
          supplier_name          varchar2(240)  path '$.supplierName',
          supplier_type          varchar2(60)   path '$.supplierType',
          active                 varchar2(10)   path '$.active',
          source_last_updated_at varchar2(40)   path '$.sourceLastUpdatedAt',
          -- Child arrays returned as JSON strings for sub-processing
          tax_registrations      clob           format json path '$.taxRegistrations',
          sites                  clob           format json path '$.sites',
          bank_accounts          clob           format json path '$.bankAccounts'
        )
      ) jt
      where jt.fusion_supplier_id is not null
        and jt.supplier_number    is not null
        and jt.supplier_name      is not null
    ) loop
      begin
        upsert_supplier(
          p_sync_id            => l_sync_id,
          p_fusion_supplier_id => s.fusion_supplier_id,
          p_supplier_number    => s.supplier_number,
          p_supplier_name      => s.supplier_name,
          p_supplier_type      => s.supplier_type,
          p_active             => s.active,
          p_source_updated_at  => s.source_last_updated_at,
          p_tax_json           => s.tax_registrations,
          p_site_json          => s.sites,
          p_bank_json          => s.bank_accounts,
          p_full_snapshot      => case when lower(l_full_snapshot) = 'true' then 'Y' else 'N' end,
          p_rejected_count     => l_rejected
        );
      exception
        when others then
          -- A header-level failure (e.g. bad supplier_id) rejects the whole supplier
          l_rejected := l_rejected + 1;
      end;
    end loop;

    -- Compute upsert deltas
    select count(*) into l_header_after from fusion_supplier_ref;
    select count(*) into l_tax_after    from fusion_supplier_tax_ref;
    select count(*) into l_site_after   from fusion_supplier_site_ref;
    select count(*) into l_bank_after   from fusion_supplier_bank_ref;

    p_header_upsert_count := l_header_after - l_header_before;
    p_tax_upsert_count    := l_tax_after    - l_tax_before;
    p_site_upsert_count   := l_site_after   - l_site_before;
    p_bank_upsert_count   := l_bank_after   - l_bank_before;
    p_rejected_count      := l_rejected;

  end process_batch;

end supplier_reference_pkg;
/
