set define off
whenever sqlerror exit sql.sqlcode

create table configuration (
  config_type varchar2(60) not null,
  config_key varchar2(120) not null,
  config_value varchar2(4000) not null,
  active char(1) default 'Y' not null,
  description varchar2(500),
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint configuration_pk primary key (config_type, config_key),
  constraint configuration_active_chk check (active in ('Y', 'N'))
);

create table risk_rule_config (
  rule_code varchar2(120) not null,
  component varchar2(20) default 'BASE' not null,
  rule_name varchar2(160) not null,
  condition_description varchar2(500) not null,
  weight_points number(5,2) not null,
  active char(1) default 'Y' not null,
  display_order number default 100 not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint risk_rule_config_pk primary key (rule_code),
  constraint risk_rule_component_chk check (component in ('BASE', 'DUPLICATE')),
  constraint risk_rule_weight_chk check (weight_points between 0 and 100),
  constraint risk_rule_active_chk check (active in ('Y', 'N'))
);

create table risk_score_band_config (
  risk_level varchar2(20) not null,
  min_score number(5,2) not null,
  max_score number(5,2) not null,
  active char(1) default 'Y' not null,
  display_order number default 100 not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint risk_score_band_config_pk primary key (risk_level),
  constraint risk_score_band_range_chk check (
    min_score between 0 and 100 and
    max_score between 0 and 100 and
    min_score <= max_score
  ),
  constraint risk_score_band_active_chk check (active in ('Y', 'N'))
);

create table high_risk_country_config (
  country_code varchar2(2) not null,
  reason varchar2(300) not null,
  source_name varchar2(120) default 'Admin' not null,
  effective_date date default trunc(current_date) not null,
  active char(1) default 'Y' not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint high_risk_country_config_pk primary key (country_code),
  constraint high_risk_country_code_chk check (regexp_like(country_code, '^[A-Z]{2}$')),
  constraint high_risk_country_active_chk check (active in ('Y', 'N'))
);

create table tax_requirement_config (
  country_code varchar2(2) not null,
  supplier_type varchar2(40) default 'ANY' not null,
  required char(1) default 'Y' not null,
  reason varchar2(300),
  active char(1) default 'Y' not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint tax_requirement_config_pk primary key (country_code, supplier_type),
  constraint tax_requirement_country_chk check (regexp_like(country_code, '^[A-Z]{2}$')),
  constraint tax_requirement_required_chk check (required in ('Y', 'N')),
  constraint tax_requirement_active_chk check (active in ('Y', 'N'))
);

create table business_unit_site_mapping (
  business_unit varchar2(120) not null,
  site_name varchar2(160) not null,
  site_country_code varchar2(2) not null,
  active char(1) default 'Y' not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint business_unit_site_mapping_pk primary key (business_unit, site_name, site_country_code),
  constraint business_unit_site_country_chk check (regexp_like(site_country_code, '^[A-Z]{2}$')),
  constraint business_unit_site_active_chk check (active in ('Y', 'N'))
);

create table generic_justification_phrase (
  phrase_key varchar2(120) not null,
  phrase_text varchar2(500) not null,
  severity varchar2(20) default 'WARNING' not null,
  active char(1) default 'Y' not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint generic_just_phrase_pk primary key (phrase_key),
  constraint generic_just_severity_chk check (severity in ('INFO', 'WARNING', 'HIGH_RISK')),
  constraint generic_just_active_chk check (active in ('Y', 'N'))
);
