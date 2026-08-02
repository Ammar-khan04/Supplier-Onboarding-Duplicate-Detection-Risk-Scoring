set define off
whenever sqlerror exit sql.sqlcode

prompt Seeding local QA IAM identity examples. Oracle IAM owns real users and roles.

insert into configuration (
  config_type,
  config_key,
  config_value,
  active,
  description,
  updated_by_subject_id
) values (
  'LOCAL_DEMO_IDENTITY',
  'REQ_AMINA_SUB',
  'Amina Requester | amina.requester@example.com | REQUESTER',
  'Y',
  'Local QA identity example only; not an ATP role assignment',
  'SYSTEM'
);

insert into configuration (
  config_type,
  config_key,
  config_value,
  active,
  description,
  updated_by_subject_id
) values (
  'LOCAL_DEMO_IDENTITY',
  'REV_PRIYA_SUB',
  'Priya Reviewer | priya.reviewer@example.com | REVIEWER',
  'Y',
  'Local QA identity example only; not an ATP role assignment',
  'SYSTEM'
);

insert into configuration (
  config_type,
  config_key,
  config_value,
  active,
  description,
  updated_by_subject_id
) values (
  'LOCAL_DEMO_IDENTITY',
  'ADM_LINDA_SUB',
  'Linda Admin | linda.admin@example.com | ADMIN',
  'Y',
  'Local QA identity example only; not an ATP role assignment',
  'SYSTEM'
);

commit;
