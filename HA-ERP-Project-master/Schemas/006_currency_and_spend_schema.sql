set define off
whenever sqlerror exit sql.sqlcode

create table currency_exchange_rate (
  currency_code varchar2(3) not null,
  to_usd_rate number not null,
  active char(1) default 'Y' not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint currency_exchange_rate_pk primary key (currency_code),
  constraint currency_exchange_rate_chk check (regexp_like(currency_code, '^[A-Z]{3}$')),
  constraint currency_rate_active_chk check (active in ('Y', 'N'))
);

create table spend_risk_band_config (
  band_name varchar2(60) not null,
  min_amount number not null,
  max_amount number,
  risk_weight_percentage number not null,
  active char(1) default 'Y' not null,
  updated_by_subject_id varchar2(200),
  updated_at timestamp with local time zone default systimestamp not null,
  constraint spend_risk_band_pk primary key (band_name),
  constraint spend_risk_band_pct_chk check (risk_weight_percentage between 0 and 100),
  constraint spend_risk_band_amt_chk check (min_amount >= 0 and (max_amount is null or max_amount >= min_amount)),
  constraint spend_risk_band_active_chk check (active in ('Y', 'N'))
);

-- Seed data
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('USD', 1.0);
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('EUR', 1.1);
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('GBP', 1.25);
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('PKR', 0.0035);
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('AED', 0.27);
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('SAR', 0.27);
insert into currency_exchange_rate (currency_code, to_usd_rate) values ('BHD', 2.65);

insert into spend_risk_band_config (band_name, min_amount, max_amount, risk_weight_percentage)
values ('Moderate Spend', 100000, 249999.99, 40);

insert into spend_risk_band_config (band_name, min_amount, max_amount, risk_weight_percentage)
values ('High Spend', 250000, 499999.99, 60);

insert into spend_risk_band_config (band_name, min_amount, max_amount, risk_weight_percentage)
values ('Critical Spend', 500000, null, 100);

commit;
