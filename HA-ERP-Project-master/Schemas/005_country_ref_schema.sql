-- 005_country_ref_schema.sql
-- Reference table for ISO 3166-1 country codes and names

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE country_ref (
      country_code   VARCHAR2(2) NOT NULL,
      country_name   VARCHAR2(100) NOT NULL,
      iso3_code      VARCHAR2(3),
      num_code       VARCHAR2(3),
      active         VARCHAR2(1) DEFAULT ''Y'' NOT NULL,
      created_at     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
      updated_at     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
      CONSTRAINT country_ref_pk PRIMARY KEY (country_code),
      CONSTRAINT country_ref_code_chk CHECK (REGEXP_LIKE(country_code, ''^[A-Z]{2}$'')),
      CONSTRAINT country_ref_active_chk CHECK (active IN (''Y'', ''N''))
    )
  ';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -955 THEN -- ORA-00955: table already exists
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE VIEW country_ref_v AS
SELECT
  country_code,
  country_name,
  country_code || ' - ' || country_name AS display_label,
  country_name || ' (' || country_code || ')' AS display_name,
  iso3_code,
  num_code,
  active,
  created_at,
  updated_at
FROM country_ref;
/
