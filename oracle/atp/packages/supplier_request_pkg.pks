create or replace package supplier_request_pkg as
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
  );

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
  );

  procedure submit_request(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_status out varchar2
  );

  procedure add_document(
    p_actor_subject_id in varchar2,
    p_actor_roles in varchar2,
    p_request_id in number,
    p_document_type in varchar2,
    p_file_name in varchar2,
    p_mime_type in varchar2 default null,
    p_document_content in blob default null,
    p_document_id out number
  );
end supplier_request_pkg;
/
