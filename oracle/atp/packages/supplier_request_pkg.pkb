create or replace package body supplier_request_pkg as
  procedure create_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_requester_display_name in varchar2,
    p_requester_email in varchar2,
    p_supplier_name in varchar2,
    p_supplier_type in varchar2,
    p_country_code in varchar2,
    p_address_line1 in varchar2,
    p_address_line2 in varchar2 default null,
    p_city in varchar2 default null,
    p_state_or_province in varchar2 default null,
    p_postal_code in varchar2 default null,
    p_contact_person in varchar2 default null,
    p_contact_email in varchar2 default null,
    p_contact_phone in varchar2 default null,
    p_business_unit in varchar2 default null,
    p_business_justification in clob default null,
    p_product_service_category in varchar2 default null,
    p_expected_annual_spend in number default null,
    p_currency_code in varchar2 default 'USD',
    p_tax_registration_number in varchar2 default null,
    p_bank_country_code in varchar2 default null,
    p_bank_currency_code in varchar2 default null,
    p_bank_account_raw in varchar2 default null,
    p_site_name in varchar2 default null,
    p_site_address_line1 in varchar2 default null,
    p_site_city in varchar2 default null,
    p_site_country_code in varchar2 default null,
    p_request_id out number
  ) is
    l_request_number varchar2(30);
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    l_request_number := 'REQ-' || to_char(supplier_request_number_seq.nextval);

    insert into supplier_request (
      request_number,
      requester_subject_id,
      requester_display_name,
      requester_email,
      supplier_name,
      supplier_name_normalized,
      supplier_type,
      country_code,
      address_line1,
      address_line2,
      city,
      state_or_province,
      postal_code,
      address_normalized,
      contact_person,
      contact_email,
      contact_phone,
      business_unit,
      business_justification,
      product_service_category,
      expected_annual_spend,
      currency_code,
      base_currency_code,
      base_currency_amount,
      conversion_rate,
      tax_registration_number,
      tax_registration_fingerprint,
      tax_registration_masked,
      bank_account_fingerprint,
      bank_account_last_four,
      bank_country_code,
      bank_currency_code,
      site_name,
      site_address_line1,
      site_city,
      site_country_code
    ) values (
      l_request_number,
      p_actor_subject_id,
      p_requester_display_name,
      p_requester_email,
      p_supplier_name,
      supplier_projection_pkg.normalize_text(p_supplier_name),
      upper(p_supplier_type),
      upper(substr(p_country_code, 1, 2)),
      p_address_line1,
      p_address_line2,
      p_city,
      p_state_or_province,
      p_postal_code,
      supplier_projection_pkg.normalize_text(p_address_line1 || ' ' || p_city || ' ' || p_country_code),
      p_contact_person,
      p_contact_email,
      p_contact_phone,
      p_business_unit,
      p_business_justification,
      p_product_service_category,
      p_expected_annual_spend,
      upper(nvl(p_currency_code, 'USD')),
      'USD',
      p_expected_annual_spend,
      1,
      p_tax_registration_number,
      supplier_projection_pkg.fingerprint(p_tax_registration_number),
      supplier_projection_pkg.mask_identifier(p_tax_registration_number),
      supplier_projection_pkg.fingerprint(p_bank_account_raw),
      case when p_bank_account_raw is null then null else substr(regexp_replace(p_bank_account_raw, '[^[:alnum:]]', ''), -4) end,
      case when p_bank_country_code is null then null else upper(substr(p_bank_country_code, 1, 2)) end,
      case when p_bank_currency_code is null then null else upper(substr(p_bank_currency_code, 1, 3)) end,
      p_site_name,
      p_site_address_line1,
      p_site_city,
      case when p_site_country_code is null then upper(substr(p_country_code, 1, 2)) else upper(substr(p_site_country_code, 1, 2)) end
    ) returning request_id into p_request_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'CREATE_DRAFT',
      p_from_status => null,
      p_to_status => 'DRAFT',
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester created draft'
    );
  end create_request;

  procedure update_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_supplier_name in varchar2 default null,
    p_supplier_type in varchar2 default null,
    p_country_code in varchar2 default null,
    p_address_line1 in varchar2 default null,
    p_address_line2 in varchar2 default null,
    p_city in varchar2 default null,
    p_state_or_province in varchar2 default null,
    p_postal_code in varchar2 default null,
    p_contact_person in varchar2 default null,
    p_contact_email in varchar2 default null,
    p_contact_phone in varchar2 default null,
    p_business_unit in varchar2 default null,
    p_business_justification in clob default null,
    p_product_service_category in varchar2 default null,
    p_expected_annual_spend in number default null,
    p_currency_code in varchar2 default null,
    p_tax_registration_number in varchar2 default null,
    p_bank_country_code in varchar2 default null,
    p_bank_currency_code in varchar2 default null,
    p_bank_account_raw in varchar2 default null,
    p_site_name in varchar2 default null,
    p_site_address_line1 in varchar2 default null,
    p_site_city in varchar2 default null,
    p_site_country_code in varchar2 default null
  ) is
    l_status supplier_request.status%type;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select status
      into l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_status not in ('DRAFT', 'VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      raise_application_error(-20040, 'Request is not editable in status ' || l_status);
    end if;

    if l_status = 'VALIDATION_FAILED' then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'DRAFT',
        p_action => 'EDIT_AFTER_VALIDATION_FAILURE',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'Requester edited validation failed request'
      );
    end if;

    update supplier_request
       set supplier_name = nvl(p_supplier_name, supplier_name),
           supplier_name_normalized = nvl(supplier_projection_pkg.normalize_text(p_supplier_name), supplier_name_normalized),
           supplier_type = nvl(upper(p_supplier_type), supplier_type),
           country_code = nvl(upper(substr(p_country_code, 1, 2)), country_code),
           address_line1 = nvl(p_address_line1, address_line1),
           address_line2 = nvl(p_address_line2, address_line2),
           city = nvl(p_city, city),
           state_or_province = nvl(p_state_or_province, state_or_province),
           postal_code = nvl(p_postal_code, postal_code),
           contact_person = nvl(p_contact_person, contact_person),
           contact_email = nvl(p_contact_email, contact_email),
           contact_phone = nvl(p_contact_phone, contact_phone),
           business_unit = nvl(p_business_unit, business_unit),
           business_justification = case when p_business_justification is null then business_justification else p_business_justification end,
           product_service_category = nvl(p_product_service_category, product_service_category),
           expected_annual_spend = nvl(p_expected_annual_spend, expected_annual_spend),
           currency_code = nvl(upper(p_currency_code), currency_code),
           base_currency_amount = nvl(p_expected_annual_spend, base_currency_amount),
           tax_registration_number = nvl(p_tax_registration_number, tax_registration_number),
           tax_registration_fingerprint = case
             when p_tax_registration_number is null then tax_registration_fingerprint
             else supplier_projection_pkg.fingerprint(p_tax_registration_number)
           end,
           tax_registration_masked = case
             when p_tax_registration_number is null then tax_registration_masked
             else supplier_projection_pkg.mask_identifier(p_tax_registration_number)
           end,
           bank_account_fingerprint = case
             when p_bank_account_raw is null then bank_account_fingerprint
             else supplier_projection_pkg.fingerprint(p_bank_account_raw)
           end,
           bank_account_last_four = case
             when p_bank_account_raw is null then bank_account_last_four
             else substr(regexp_replace(p_bank_account_raw, '[^[:alnum:]]', ''), -4)
           end,
           bank_country_code = nvl(upper(substr(p_bank_country_code, 1, 2)), bank_country_code),
           bank_currency_code = nvl(upper(substr(p_bank_currency_code, 1, 3)), bank_currency_code),
           site_name = nvl(p_site_name, site_name),
           site_address_line1 = nvl(p_site_address_line1, site_address_line1),
           site_city = nvl(p_site_city, site_city),
           site_country_code = nvl(upper(substr(p_site_country_code, 1, 2)), site_country_code),
           address_normalized = supplier_projection_pkg.normalize_text(
             nvl(p_address_line1, address_line1) || ' ' ||
             nvl(p_city, city) || ' ' ||
             nvl(p_country_code, country_code)
           ),
           updated_at = systimestamp
     where request_id = p_request_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'UPDATE_REQUEST',
      p_from_status => case when l_status = 'VALIDATION_FAILED' then 'DRAFT' else l_status end,
      p_to_status => case when l_status = 'VALIDATION_FAILED' then 'DRAFT' else l_status end,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester updated editable request'
    );
  end update_request;

  procedure submit_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_status out varchar2
  ) is
    l_status supplier_request.status%type;
    l_assessment_id number;
    l_validation_status request_assessment.validation_status%type;
    l_job_id number;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select status
      into l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    if l_status not in ('DRAFT', 'VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      raise_application_error(-20041, 'Request cannot be submitted from status ' || l_status);
    end if;

    if l_status in ('VALIDATION_FAILED', 'CORRECTION_REQUIRED') then
      update supplier_request
         set request_version = request_version + 1,
             updated_at = systimestamp
       where request_id = p_request_id;
    end if;

    supplier_workflow_pkg.transition_request(
      p_request_id => p_request_id,
      p_to_status => 'SUBMITTED',
      p_action => 'SUBMIT',
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester submitted request'
    );

    supplier_validation_pkg.assess_request(
      p_request_id => p_request_id,
      p_actor_subject_id => p_actor_subject_id,
      p_assessment_id => l_assessment_id
    );

    select validation_status
      into l_validation_status
      from request_assessment
     where assessment_id = l_assessment_id;

    if l_validation_status = 'FAILED' then
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'VALIDATION_FAILED',
        p_action => 'VALIDATION_FAILED',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'ATP validation blocked submission'
      );
    else
      supplier_workflow_pkg.transition_request(
        p_request_id => p_request_id,
        p_to_status => 'UNDER_REVIEW',
        p_action => 'VALIDATION_PASSED',
        p_actor_subject_id => p_actor_subject_id,
        p_reason => 'ATP assessment routed request to reviewer queue'
      );

      supplier_integration_pkg.create_job(
        p_request_id => p_request_id,
        p_integration_type => 'AI_EXPLANATION',
        p_payload_reference => 'REQUEST:' || to_char(p_request_id) || ':VERSION',
        p_job_id => l_job_id
      );
    end if;

    select status
      into p_status
      from supplier_request
     where request_id = p_request_id;
  end submit_request;

  procedure add_document(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_document_type in varchar2,
    p_file_name in varchar2,
    p_mime_type in varchar2 default null,
    p_document_content in blob default null,
    p_document_id out number
  ) is
    l_version number;
    l_status supplier_request.status%type;
  begin
    supplier_auth_pkg.require_role(p_actor_roles, 'REQUESTER');
    supplier_auth_pkg.assert_request_access(p_actor_subject_id, p_actor_roles, p_request_id);

    select request_version, status
      into l_version, l_status
      from supplier_request
     where request_id = p_request_id
     for update;

    update request_document
       set is_latest = 'N'
     where request_id = p_request_id
       and document_type = upper(p_document_type)
       and is_latest = 'Y';

    insert into request_document (
      request_id,
      request_version,
      document_type,
      file_name,
      mime_type,
      document_content,
      is_latest,
      uploaded_by_subject_id
    ) values (
      p_request_id,
      l_version,
      upper(p_document_type),
      p_file_name,
      p_mime_type,
      p_document_content,
      'Y',
      p_actor_subject_id
    ) returning document_id into p_document_id;

    supplier_workflow_pkg.write_action(
      p_request_id => p_request_id,
      p_action => 'UPLOAD_DOCUMENT',
      p_from_status => l_status,
      p_to_status => l_status,
      p_actor_subject_id => p_actor_subject_id,
      p_reason => 'Requester uploaded or replaced a document'
    );
  end add_document;
end supplier_request_pkg;
/
