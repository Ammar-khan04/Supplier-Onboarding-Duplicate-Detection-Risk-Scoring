   set define off
whenever sqlerror exit sql.sqlcode

begin
   dbms_utility.compile_schema(
      schema      => user,
      compile_all => false
   );
end;
/

begin
   begin
      ords.delete_module(p_module_name => 'ha_supplier_onboarding_v1');
   exception
      when others then
         null;
   end;

   ords.define_module(
      p_module_name    => 'ha_supplier_onboarding_v1',
      p_base_path      => 'ha_v1/',
      p_items_per_page => 25,
      p_status         => 'PUBLISHED',
      p_comments       => 'Supplier Onboarding finalized ATP/ORDS foundation API'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => '/'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => '/',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_item,
      p_source      => q'[
      select
        'supplier-onboarding-ords' as service_name,
        'v1' as api_version,
        'Use /health, /requests, /risk-rules, /high-risk-countries, /integration-logs, or /integration-jobs.' as available_resources,
        systimestamp as checked_at
      from dual
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'health'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'health',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_item,
      p_source      => q'[
      select
        'ok' as status,
        'supplier-onboarding-ords' as service_name,
        systimestamp as checked_at
      from dual
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
      select
        d.*,
        supplier_projection_pkg.allowed_actions(
          coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          coalesce(:actor_roles, 'REQUESTER'),
          d.request_id
        ) as allowed_actions
      from request_dashboard_v d
      where d.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
         or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
         or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN') = 'Y'
      order by d.updated_at desc
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only
    ]'
   );
   ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'requests',
      p_method             => 'GET',
      p_name               => 'actor_subject_id',
      p_bind_variable_name => 'actor_subject_id',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => 'Actor identity from HTTP header'
   );
   ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'requests',
      p_method             => 'GET',
      p_name               => 'actor_roles',
      p_bind_variable_name => 'actor_roles',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => 'Actor roles from HTTP header'
   );

   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      declare
        l_request_id number;
      begin
        supplier_request_pkg.create_request(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REQUESTER'),
          p_requester_display_name => :requester_display_name,
          p_requester_email => :requester_email,
          p_supplier_name => :supplier_name,
          p_supplier_type => :supplier_type,
          p_country_code => :country_code,
          p_address_line1 => :address_line1,
          p_address_line2 => :address_line2,
          p_city => :city,
          p_state_or_province => :state_or_province,
          p_postal_code => :postal_code,
          p_contact_person => :contact_person,
          p_contact_email => :contact_email,
          p_contact_phone => :contact_phone,
          p_business_unit => :business_unit,
          p_business_justification => :business_justification,
          p_product_service_category => :product_service_category,
          p_expected_annual_spend => case when :expected_annual_spend is null then null else to_number(:expected_annual_spend) end,
          p_currency_code => coalesce(:currency_code, 'USD'),
          p_tax_registration_number => :tax_registration_number,
          p_bank_country_code => :bank_country_code,
          p_bank_currency_code => :bank_currency_code,
          p_bank_account_raw => :bank_account_raw,
          p_site_name => :site_name,
          p_site_address_line1 => :site_address_line1,
          p_site_city => :site_city,
          p_site_country_code => :site_country_code,
          p_request_id => l_request_id
        );
        :status_code := 201;
        owa_util.mime_header('application/json', true);
        htp.p('{"request_id":' || to_char(l_request_id) || '}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_item,
      p_source      => q'[
      select
        d.*,
        supplier_projection_pkg.allowed_actions(
          coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          coalesce(:actor_roles, 'REQUESTER'),
          d.request_id
        ) as allowed_actions
      from request_detail_safe_v d
      where d.request_id = to_number(:request_id)
        and (
          d.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
          or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
          or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN') = 'Y'
        )
    ]'
   );
   ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'requests/:request_id',
      p_method             => 'GET',
      p_name               => 'actor_subject_id',
      p_bind_variable_name => 'actor_subject_id',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => 'Actor identity from HTTP header'
   );
   ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'requests/:request_id',
      p_method             => 'GET',
      p_name               => 'actor_roles',
      p_bind_variable_name => 'actor_roles',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => 'Actor roles from HTTP header'
   );

   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id',
      p_method      => 'PUT',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_request_pkg.update_request(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REQUESTER'),
          p_request_id => to_number(:request_id),
          p_supplier_name => :supplier_name,
          p_supplier_type => :supplier_type,
          p_country_code => :country_code,
          p_address_line1 => :address_line1,
          p_address_line2 => :address_line2,
          p_city => :city,
          p_state_or_province => :state_or_province,
          p_postal_code => :postal_code,
          p_contact_person => :contact_person,
          p_contact_email => :contact_email,
          p_contact_phone => :contact_phone,
          p_business_unit => :business_unit,
          p_business_justification => :business_justification,
          p_product_service_category => :product_service_category,
          p_expected_annual_spend => case when :expected_annual_spend is null then null else to_number(:expected_annual_spend) end,
          p_currency_code => :currency_code,
          p_tax_registration_number => :tax_registration_number,
          p_bank_country_code => :bank_country_code,
          p_bank_currency_code => :bank_currency_code,
          p_bank_account_raw => :bank_account_raw,
          p_site_name => :site_name,
          p_site_address_line1 => :site_address_line1,
          p_site_city => :site_city,
          p_site_country_code => :site_country_code
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "updated"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/submit'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/submit',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      declare
        l_status varchar2(40);
      begin
        supplier_request_pkg.submit_request(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REQUESTER'),
          p_request_id => to_number(:request_id),
          p_status => l_status
        );
        owa_util.mime_header('application/json', true);
        htp.p('{"status":"' || l_status || '"}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
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
      from request_document
      where request_id = to_number(:request_id)
        and is_latest = 'Y'
      order by uploaded_at desc
    ]'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      declare
        l_document_id number;
        l_b64 clob;
        l_doc_type varchar2(100);
        l_file_name varchar2(255);
        l_mime_type varchar2(100);
      begin
        begin
          if :body_text is not null then
            l_b64 := json_value(:body_text, '$.document_content_base64' returning clob);
            l_doc_type := json_value(:body_text, '$.document_type');
            l_file_name := json_value(:body_text, '$.file_name');
            l_mime_type := json_value(:body_text, '$.mime_type');
          end if;
        exception
          when others then
            null;
        end;

        if l_b64 is null then
          l_b64 := :document_content_base64;
        end if;
        if l_doc_type is null then
          l_doc_type := :document_type;
        end if;
        if l_file_name is null then
          l_file_name := :file_name;
        end if;
        if l_mime_type is null then
          l_mime_type := :mime_type;
        end if;

        supplier_request_pkg.add_document(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REQUESTER'),
          p_request_id => to_number(:request_id),
          p_document_type => l_doc_type,
          p_file_name => l_file_name,
          p_mime_type => l_mime_type,
          p_document_content => null,
          p_document_content_base64 => l_b64,
          p_document_id => l_document_id
        );
        :status_code := 201;
        owa_util.mime_header('application/json', true);
        htp.p('{"document_id":' || to_char(l_document_id) || '}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents/:document_id'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents/:document_id',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_item,
      p_source      => q'[
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
      from request_document
      where request_id = to_number(:request_id)
        and document_id = to_number(:document_id)
    ]'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents/:document_id',
      p_method      => 'DELETE',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_request_pkg.delete_document(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REQ_AMINA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REQUESTER'),
          p_request_id => to_number(:request_id),
          p_document_id => to_number(:document_id)
        );
        :status_code := 200;
        owa_util.mime_header('application/json', true);
        htp.p('{"status":"DELETED","document_id":' || to_char(:document_id) || '}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents/:document_id/content'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/documents/:document_id/content',
      p_method      => 'GET',
      p_source_type => ords.source_type_media,
      p_source      => q'[
      select
        nvl(mime_type, 'application/pdf') as mime_type,
        document_content
      from request_document
      where request_id = to_number(:request_id)
        and document_id = to_number(:document_id)
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/review'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/review',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_review_pkg.decide_request(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REV_PRIYA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REVIEWER'),
          p_request_id => to_number(:request_id),
          p_decision => :decision,
          p_reason => :reason,
          p_existing_supplier_id => :existing_supplier_id
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "review_decision_recorded"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/justification-risk-adjustment'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/justification-risk-adjustment',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_review_pkg.apply_justification_risk_adjustment(
          p_actor_subject_id => coalesce(:actor_subject_id, 'REV_PRIYA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'REVIEWER'),
          p_request_id => to_number(:request_id),
          p_points => to_number(:points),
          p_reason => :reason
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "justification_risk_adjusted"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/ai-regeneration'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/ai-regeneration',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      declare
        l_job_id number;
      begin
        supplier_auth_pkg.require_role(coalesce(:actor_roles, 'REVIEWER'), 'REVIEWER');
        supplier_integration_pkg.create_job(
          p_request_id => to_number(:request_id),
          p_integration_type => 'AI_EXPLANATION',
          p_payload_reference => 'REQUEST:' || :request_id || ':AI_REGENERATION',
          p_job_id => l_job_id
        );
        owa_util.mime_header('application/json', true);
        htp.p('{"job_id":' || to_char(l_job_id) || '}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/retry'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'requests/:request_id/retry',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      declare
        l_job_id number;
      begin
        supplier_integration_pkg.retry_latest_failed_request_job(
          p_actor_subject_id => coalesce(:actor_subject_id, 'ADM_LINDA_SUB'),
          p_actor_roles => coalesce(:actor_roles, 'ADMIN'),
          p_request_id => to_number(:request_id),
          p_new_job_id => l_job_id
        );
        :status_code := 201;
        owa_util.mime_header('application/json', true);
        htp.p('{"job_id":' || to_char(l_job_id) || '}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-logs'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-logs',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
      select *
      from integration_log_safe_v
      where (:type is null or integration_type = upper(:type))
        and (:status is null or status = upper(:status))
      order by updated_at desc
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-jobs'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-jobs',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
      select *
      from integration_log_safe_v
      where (:type is null or integration_type = upper(:type))
        and (:status is null or status = upper(:status))
      order by created_at
      offset nvl(to_number(:offset), 0) rows
      fetch next nvl(to_number(:limit), 25) rows only
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-jobs/:job_id/claim'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-jobs/:job_id/claim',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_integration_pkg.claim_job(
          p_job_id => to_number(:job_id),
          p_oic_instance_id => :oic_instance_id,
          p_correlation_id => :correlation_id
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "claimed"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-jobs/:job_id/result'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'integration-jobs/:job_id/result',
      p_method      => 'PUT',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_integration_pkg.complete_job(
          p_job_id => to_number(:job_id),
          p_status => :job_status,
          p_response_reference => :response_reference,
          p_error_type => :error_type,
          p_error_message => :error_message,
          p_retryable => coalesce(:retryable, 'N'),
          p_fusion_supplier_id => :fusion_supplier_id,
          p_fusion_supplier_number => :fusion_supplier_number,
          p_ai_summary => :ai_summary,
          p_ai_recommended_actions => :ai_recommended_actions,
          p_justification_quality => coalesce(:justification_quality, 'UNKNOWN'),
          p_model_name => :model_name
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "recorded"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'supplier-reference/batch'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'supplier-reference/batch',
      p_method      => 'POST',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        merge into fusion_supplier_ref t
        using (
          select
            :fusion_supplier_id as fusion_supplier_id,
            :supplier_number as supplier_number,
            :supplier_name as supplier_name,
            supplier_projection_pkg.normalize_text(:supplier_name) as supplier_name_normalized,
            :supplier_type as supplier_type,
            coalesce(:sync_id, 'MANUAL_SYNC') as sync_id
          from dual
        ) s
        on (t.fusion_supplier_id = s.fusion_supplier_id)
        when matched then update set
          t.supplier_number = s.supplier_number,
          t.supplier_name = s.supplier_name,
          t.supplier_name_normalized = s.supplier_name_normalized,
          t.supplier_type = s.supplier_type,
          t.active = 'Y',
          t.last_seen_sync_id = s.sync_id,
          t.last_synced_at = systimestamp
        when not matched then insert (
          fusion_supplier_id,
          supplier_number,
          supplier_name,
          supplier_name_normalized,
          supplier_type,
          active,
          last_seen_sync_id
        ) values (
          s.fusion_supplier_id,
          s.supplier_number,
          s.supplier_name,
          s.supplier_name_normalized,
          s.supplier_type,
          'Y',
          s.sync_id
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "supplier_reference_received"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-rules'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-rules',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
      select *
      from risk_rule_config_v
      order by component, rule_code
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-rules/:rule_code'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-rules/:rule_code',
      p_method      => 'PUT',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_auth_pkg.require_role(coalesce(:actor_roles, 'ADMIN'), 'ADMIN');
        supplier_config_pkg.update_risk_rule(
          p_actor_subject_id => coalesce(:actor_subject_id, 'ADM_LINDA_SUB'),
          p_rule_code => :rule_code,
          p_weight => to_number(:weight),
          p_active => coalesce(:active, 'Y')
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "risk_rule_updated"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-bands'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-bands',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => 'select risk_level, min_score, max_score, active, display_order, updated_by_subject_id, updated_at from risk_score_band_config order by min_score'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-bands/:risk_level'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'risk-bands/:risk_level',
      p_method      => 'PUT',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_auth_pkg.require_role(coalesce(:actor_roles, 'ADMIN'), 'ADMIN');
        supplier_config_pkg.update_risk_score_band(
          p_actor_subject_id => coalesce(:actor_subject_id, 'ADM_LINDA_SUB'),
          p_risk_level => :risk_level,
          p_min_score => to_number(:min_score),
          p_max_score => to_number(:max_score)
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "risk_band_updated"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'high-risk-countries'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'high-risk-countries',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
      select *
      from high_risk_country_config_v
      order by country_code
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'high-risk-countries/:country_code'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'high-risk-countries/:country_code',
      p_method      => 'PUT',
      p_source_type => ords.source_type_plsql,
      p_source      => q'[
      begin
        supplier_auth_pkg.require_role(coalesce(:actor_roles, 'ADMIN'), 'ADMIN');
        supplier_config_pkg.set_high_risk_country(
          p_actor_subject_id => coalesce(:actor_subject_id, 'ADM_LINDA_SUB'),
          p_country_code => :country_code,
          p_active => coalesce(:active, 'Y'),
          p_reason => :reason,
          p_source => :source
        );
        owa_util.mime_header('application/json', true);
        htp.p('{
  "status": "high_risk_country_updated"
}');
      end;
    ]'
   );

   ords.define_template(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'action-history'
   );
   ords.define_handler(
      p_module_name => 'ha_supplier_onboarding_v1',
      p_pattern     => 'action-history',
      p_method      => 'GET',
      p_source_type => ords.source_type_collection_feed,
      p_source      => q'[
    select
      ah.action_history_id as history_id,
      ah.request_id,
      sr.request_number,
      sr.supplier_name,
      sr.business_unit,
      sr.requester_subject_id,
      ah.action          as action_type,
      ah.from_status     as previous_status,
      ah.to_status       as new_status,
      ah.actor_subject_id,
      ah.reason          as action_note,
      ah.existing_supplier_id,
      ah.action_at
    from action_history ah
    join supplier_request sr on sr.request_id = ah.request_id
    where (
      supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'ADMIN')    = 'Y'
      or supplier_auth_pkg.has_role(coalesce(:actor_roles, 'REQUESTER'), 'REVIEWER') = 'Y'
      or sr.requester_subject_id = coalesce(:actor_subject_id, 'REQ_AMINA_SUB')
    )
    and (:action_type is null or ah.action = upper(:action_type))
    order by ah.action_at desc
    offset nvl(to_number(:offset), 0) rows
    fetch next nvl(to_number(:limit), 200) rows only
  ]'
   );

-- Add header bindings for this endpoint too:
   ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'action-history',
      p_method             => 'GET',
      p_name               => 'actor_subject_id',
      p_bind_variable_name => 'actor_subject_id',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN'
   );
   ords.define_parameter(
      p_module_name        => 'ha_supplier_onboarding_v1',
      p_pattern            => 'action-history',
      p_method             => 'GET',
      p_name               => 'actor_roles',
      p_bind_variable_name => 'actor_roles',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN'
   );

   commit;
end;
/