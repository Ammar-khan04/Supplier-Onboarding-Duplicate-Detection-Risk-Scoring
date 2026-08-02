-- =============================================================================
-- Session 4: Updated ORDS handler for POST /supplier-reference/batch
--
-- Replaces the header-only MERGE with a call to supplier_reference_pkg.process_batch,
-- which handles all four reference tables (header + tax + site + bank).
--
-- To apply: run this script in your schema after deploying SUPPLIER_REFERENCE_PKG.sql.
-- It re-registers only the supplier-reference/batch handler; all other ORDS routes
-- are unchanged.
-- =============================================================================

set define off
whenever sqlerror exit sql.sqlcode

begin
  -- Re-register just the batch handler. The module and template already exist
  -- from the original 001_supplier_onboarding_module.sql, so we only need to
  -- replace the handler. Deleting and re-adding avoids source drift.
  begin
    ords.delete_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'supplier-reference/batch',
      p_method      => 'POST'
    );
  exception
    when others then null;  -- handler may not exist yet; safe to continue
  end;

  ords.define_handler(
    p_module_name => 'ha_supplier_onboarding_v1',
    p_pattern     => 'supplier-reference/batch',
    p_method      => 'POST',
    p_source_type => ords.source_type_plsql,
    p_source      => q'[
      declare
        l_body         clob;
        l_sync_id      varchar2(120);
        l_hdr_count    number;
        l_tax_count    number;
        l_site_count   number;
        l_bank_count   number;
        l_rejected     number;
      begin
        -- Read the full request body
        l_body := :body;

        if l_body is null or length(trim(l_body)) = 0 then
          owa_util.status_line(400, 'Bad Request');
          owa_util.mime_header('application/json', true);
          htp.p('{"code":"EMPTY_PAYLOAD","message":"Request body is required."}');
          return;
        end if;

        -- Delegate all processing to the package; it validates and commits nothing
        -- (ORDS autocommits after the handler completes without error).
        supplier_reference_pkg.process_batch(
          p_payload_json        => l_body,
          p_sync_id             => l_sync_id,
          p_header_upsert_count => l_hdr_count,
          p_tax_upsert_count    => l_tax_count,
          p_site_upsert_count   => l_site_count,
          p_bank_upsert_count   => l_bank_count,
          p_rejected_count      => l_rejected
        );

        owa_util.mime_header('application/json', true);
        htp.p(
          '{"status":"ok"' ||
          ',"syncId":"'        || l_sync_id   || '"' ||
          ',"headerUpserted":' || l_hdr_count  ||
          ',"taxUpserted":'    || l_tax_count  ||
          ',"siteUpserted":'   || l_site_count ||
          ',"bankUpserted":'   || l_bank_count ||
          ',"rejected":'       || l_rejected   ||
          '}'
        );

      exception
        when others then
          owa_util.status_line(400, 'Bad Request');
          owa_util.mime_header('application/json', true);
          htp.p(
            '{"code":"BATCH_PROCESSING_ERROR"' ||
            ',"message":"' || replace(sqlerrm, '"', '''') || '"}'
          );
      end;
    ]'
  );

  -- Bind :body to the POST request body
  begin
    ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'supplier-reference/batch',
      p_method             => 'POST',
      p_name               => 'body',
      p_bind_variable_name => 'body',
      p_source_type        => 'BODY',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => 'Full JSON batch payload'
    );
  exception
    when others then null;  -- parameter may already be registered
  end;

  commit;
end;
/
