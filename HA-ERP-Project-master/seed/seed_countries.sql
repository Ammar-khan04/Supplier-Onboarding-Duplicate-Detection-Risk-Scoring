-- seed_countries.sql
-- Standalone seed script for COUNTRY_REF table
BEGIN
  MERGE INTO country_ref t
  USING (SELECT 'AD' AS country_code, 'Andorra' AS country_name, 'AND' AS iso3_code, '020' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AE' AS country_code, 'United Arab Emirates' AS country_name, 'ARE' AS iso3_code, '784' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AF' AS country_code, 'Afghanistan' AS country_name, 'AFG' AS iso3_code, '004' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AG' AS country_code, 'Antigua and Barbuda' AS country_name, 'ATG' AS iso3_code, '028' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AI' AS country_code, 'Anguilla' AS country_name, 'AIA' AS iso3_code, '660' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AL' AS country_code, 'Albania' AS country_name, 'ALB' AS iso3_code, '008' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AM' AS country_code, 'Armenia' AS country_name, 'ARM' AS iso3_code, '051' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AO' AS country_code, 'Angola' AS country_name, 'AGO' AS iso3_code, '024' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AQ' AS country_code, 'Antarctica' AS country_name, 'ATA' AS iso3_code, '010' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AR' AS country_code, 'Argentina' AS country_name, 'ARG' AS iso3_code, '032' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AS' AS country_code, 'American Samoa' AS country_name, 'ASM' AS iso3_code, '016' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AT' AS country_code, 'Austria' AS country_name, 'AUT' AS iso3_code, '040' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AU' AS country_code, 'Australia' AS country_name, 'AUS' AS iso3_code, '036' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AW' AS country_code, 'Aruba' AS country_name, 'ABW' AS iso3_code, '533' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AX' AS country_code, 'Aland Islands' AS country_name, 'ALA' AS iso3_code, '248' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'AZ' AS country_code, 'Azerbaijan' AS country_name, 'AZE' AS iso3_code, '031' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BA' AS country_code, 'Bosnia and Herzegovina' AS country_name, 'BIH' AS iso3_code, '070' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BB' AS country_code, 'Barbados' AS country_name, 'BRB' AS iso3_code, '052' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BD' AS country_code, 'Bangladesh' AS country_name, 'BGD' AS iso3_code, '050' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BE' AS country_code, 'Belgium' AS country_name, 'BEL' AS iso3_code, '056' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BF' AS country_code, 'Burkina Faso' AS country_name, 'BFA' AS iso3_code, '854' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BG' AS country_code, 'Bulgaria' AS country_name, 'BGR' AS iso3_code, '100' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BH' AS country_code, 'Bahrain' AS country_name, 'BHR' AS iso3_code, '048' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BI' AS country_code, 'Burundi' AS country_name, 'BDI' AS iso3_code, '108' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BJ' AS country_code, 'Benin' AS country_name, 'BEN' AS iso3_code, '204' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BL' AS country_code, 'Saint Barthelemy' AS country_name, 'BLM' AS iso3_code, '652' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BM' AS country_code, 'Bermuda' AS country_name, 'BMU' AS iso3_code, '060' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BN' AS country_code, 'Brunei Darussalam' AS country_name, 'BRN' AS iso3_code, '096' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BO' AS country_code, 'Bolivia' AS country_name, 'BOL' AS iso3_code, '068' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BQ' AS country_code, 'Bonaire, Sint Eustatius and Saba' AS country_name, 'BES' AS iso3_code, '535' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BR' AS country_code, 'Brazil' AS country_name, 'BRA' AS iso3_code, '076' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BS' AS country_code, 'Bahamas' AS country_name, 'BHS' AS iso3_code, '044' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BT' AS country_code, 'Bhutan' AS country_name, 'BTN' AS iso3_code, '064' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BV' AS country_code, 'Bouvet Island' AS country_name, 'BVT' AS iso3_code, '074' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BW' AS country_code, 'Botswana' AS country_name, 'BWA' AS iso3_code, '072' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BY' AS country_code, 'Belarus' AS country_name, 'BLR' AS iso3_code, '112' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'BZ' AS country_code, 'Belize' AS country_name, 'BLZ' AS iso3_code, '084' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CA' AS country_code, 'Canada' AS country_name, 'CAN' AS iso3_code, '124' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CC' AS country_code, 'Cocos (Keeling) Islands' AS country_name, 'CCK' AS iso3_code, '166' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CD' AS country_code, 'Congo, Democratic Republic of the' AS country_name, 'COD' AS iso3_code, '180' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CF' AS country_code, 'Central African Republic' AS country_name, 'CAF' AS iso3_code, '140' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CG' AS country_code, 'Congo' AS country_name, 'COG' AS iso3_code, '178' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CH' AS country_code, 'Switzerland' AS country_name, 'CHE' AS iso3_code, '756' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CI' AS country_code, 'Cote d''Ivoire' AS country_name, 'CIV' AS iso3_code, '384' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CK' AS country_code, 'Cook Islands' AS country_name, 'COK' AS iso3_code, '184' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CL' AS country_code, 'Chile' AS country_name, 'CHL' AS iso3_code, '152' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CM' AS country_code, 'Cameroon' AS country_name, 'CMR' AS iso3_code, '120' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CN' AS country_code, 'China' AS country_name, 'CHN' AS iso3_code, '156' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CO' AS country_code, 'Colombia' AS country_name, 'COL' AS iso3_code, '170' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CR' AS country_code, 'Costa Rica' AS country_name, 'CRI' AS iso3_code, '188' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CU' AS country_code, 'Cuba' AS country_name, 'CUB' AS iso3_code, '192' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CV' AS country_code, 'Cabo Verde' AS country_name, 'CPV' AS iso3_code, '132' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CW' AS country_code, 'Curacao' AS country_name, 'CUW' AS iso3_code, '531' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CX' AS country_code, 'Christmas Island' AS country_name, 'CXR' AS iso3_code, '162' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CY' AS country_code, 'Cyprus' AS country_name, 'CYP' AS iso3_code, '196' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'CZ' AS country_code, 'Czech Republic' AS country_name, 'CZE' AS iso3_code, '203' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'DE' AS country_code, 'Germany' AS country_name, 'DEU' AS iso3_code, '276' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'DJ' AS country_code, 'Djibouti' AS country_name, 'DJI' AS iso3_code, '262' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'DK' AS country_code, 'Denmark' AS country_name, 'DNK' AS iso3_code, '208' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'DM' AS country_code, 'Dominica' AS country_name, 'DMA' AS iso3_code, '212' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'DO' AS country_code, 'Dominican Republic' AS country_name, 'DOM' AS iso3_code, '214' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'DZ' AS country_code, 'Algeria' AS country_name, 'DZA' AS iso3_code, '012' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'EC' AS country_code, 'Ecuador' AS country_name, 'ECU' AS iso3_code, '218' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'EE' AS country_code, 'Estonia' AS country_name, 'EST' AS iso3_code, '233' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'EG' AS country_code, 'Egypt' AS country_name, 'EGY' AS iso3_code, '818' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'EH' AS country_code, 'Western Sahara' AS country_name, 'ESH' AS iso3_code, '732' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ER' AS country_code, 'Eritrea' AS country_name, 'ERI' AS iso3_code, '232' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ES' AS country_code, 'Spain' AS country_name, 'ESP' AS iso3_code, '724' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ET' AS country_code, 'Ethiopia' AS country_name, 'ETH' AS iso3_code, '231' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'FI' AS country_code, 'Finland' AS country_name, 'FIN' AS iso3_code, '246' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'FJ' AS country_code, 'Fiji' AS country_name, 'FJI' AS iso3_code, '242' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'FK' AS country_code, 'Falkland Islands' AS country_name, 'FLK' AS iso3_code, '238' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'FM' AS country_code, 'Micronesia' AS country_name, 'FSM' AS iso3_code, '583' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'FO' AS country_code, 'Faroe Islands' AS country_name, 'FRO' AS iso3_code, '234' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'FR' AS country_code, 'France' AS country_name, 'FRA' AS iso3_code, '250' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GA' AS country_code, 'Gabon' AS country_name, 'GAB' AS iso3_code, '266' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GB' AS country_code, 'United Kingdom' AS country_name, 'GBR' AS iso3_code, '826' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GD' AS country_code, 'Grenada' AS country_name, 'GRD' AS iso3_code, '308' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GE' AS country_code, 'Georgia' AS country_name, 'GEO' AS iso3_code, '268' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GF' AS country_code, 'French Guiana' AS country_name, 'GUF' AS iso3_code, '254' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GG' AS country_code, 'Guernsey' AS country_name, 'GGY' AS iso3_code, '831' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GH' AS country_code, 'Ghana' AS country_name, 'GHA' AS iso3_code, '288' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GI' AS country_code, 'Gibraltar' AS country_name, 'GIB' AS iso3_code, '292' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GL' AS country_code, 'Greenland' AS country_name, 'GRL' AS iso3_code, '304' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GM' AS country_code, 'Gambia' AS country_name, 'GMB' AS iso3_code, '270' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GN' AS country_code, 'Guinea' AS country_name, 'GIN' AS iso3_code, '324' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GP' AS country_code, 'Guadeloupe' AS country_name, 'GLP' AS iso3_code, '312' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GQ' AS country_code, 'Equatorial Guinea' AS country_name, 'GNQ' AS iso3_code, '226' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GR' AS country_code, 'Greece' AS country_name, 'GRC' AS iso3_code, '300' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GS' AS country_code, 'South Georgia and the South Sandwich Islands' AS country_name, 'SGS' AS iso3_code, '239' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GT' AS country_code, 'Guatemala' AS country_name, 'GTM' AS iso3_code, '320' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GU' AS country_code, 'Guam' AS country_name, 'GUM' AS iso3_code, '316' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GW' AS country_code, 'Guinea-Bissau' AS country_name, 'GNB' AS iso3_code, '624' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'GY' AS country_code, 'Guyana' AS country_name, 'GUY' AS iso3_code, '328' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'HK' AS country_code, 'Hong Kong' AS country_name, 'HKG' AS iso3_code, '344' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'HM' AS country_code, 'Heard Island and McDonald Islands' AS country_name, 'HMD' AS iso3_code, '334' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'HN' AS country_code, 'Honduras' AS country_name, 'HND' AS iso3_code, '340' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'HR' AS country_code, 'Croatia' AS country_name, 'HRV' AS iso3_code, '191' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'HT' AS country_code, 'Haiti' AS country_name, 'HTI' AS iso3_code, '332' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'HU' AS country_code, 'Hungary' AS country_name, 'HUN' AS iso3_code, '348' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ID' AS country_code, 'Indonesia' AS country_name, 'IDN' AS iso3_code, '360' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IE' AS country_code, 'Ireland' AS country_name, 'IRL' AS iso3_code, '372' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IL' AS country_code, 'Israel' AS country_name, 'ISR' AS iso3_code, '376' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IM' AS country_code, 'Isle of Man' AS country_name, 'IMN' AS iso3_code, '833' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IN' AS country_code, 'India' AS country_name, 'IND' AS iso3_code, '356' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IO' AS country_code, 'British Indian Ocean Territory' AS country_name, 'IOT' AS iso3_code, '086' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IQ' AS country_code, 'Iraq' AS country_name, 'IRQ' AS iso3_code, '368' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IR' AS country_code, 'Iran' AS country_name, 'IRN' AS iso3_code, '364' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IS' AS country_code, 'Iceland' AS country_name, 'ISL' AS iso3_code, '352' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'IT' AS country_code, 'Italy' AS country_name, 'ITA' AS iso3_code, '380' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'JE' AS country_code, 'Jersey' AS country_name, 'JEY' AS iso3_code, '832' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'JM' AS country_code, 'Jamaica' AS country_name, 'JAM' AS iso3_code, '388' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'JO' AS country_code, 'Jordan' AS country_name, 'JOR' AS iso3_code, '400' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'JP' AS country_code, 'Japan' AS country_name, 'JPN' AS iso3_code, '392' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KE' AS country_code, 'Kenya' AS country_name, 'KEN' AS iso3_code, '404' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KG' AS country_code, 'Kyrgyzstan' AS country_name, 'KGZ' AS iso3_code, '417' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KH' AS country_code, 'Cambodia' AS country_name, 'KHM' AS iso3_code, '116' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KI' AS country_code, 'Kiribati' AS country_name, 'KIR' AS iso3_code, '296' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KM' AS country_code, 'Comoros' AS country_name, 'COM' AS iso3_code, '174' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KN' AS country_code, 'Saint Kitts and Nevis' AS country_name, 'KNA' AS iso3_code, '659' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KP' AS country_code, 'Korea, Democratic People''s Republic of' AS country_name, 'PRK' AS iso3_code, '408' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KR' AS country_code, 'Korea, Republic of' AS country_name, 'KOR' AS iso3_code, '410' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KW' AS country_code, 'Kuwait' AS country_name, 'KWT' AS iso3_code, '414' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KY' AS country_code, 'Cayman Islands' AS country_name, 'CYM' AS iso3_code, '136' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'KZ' AS country_code, 'Kazakhstan' AS country_name, 'KAZ' AS iso3_code, '398' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LA' AS country_code, 'Lao People''s Democratic Republic' AS country_name, 'LAO' AS iso3_code, '418' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LB' AS country_code, 'Lebanon' AS country_name, 'LBN' AS iso3_code, '422' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LC' AS country_code, 'Saint Lucia' AS country_name, 'LCA' AS iso3_code, '662' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LI' AS country_code, 'Liechtenstein' AS country_name, 'LIE' AS iso3_code, '438' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LK' AS country_code, 'Sri Lanka' AS country_name, 'LKA' AS iso3_code, '144' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LR' AS country_code, 'Liberia' AS country_name, 'LBR' AS iso3_code, '430' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LS' AS country_code, 'Lesotho' AS country_name, 'LSO' AS iso3_code, '426' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LT' AS country_code, 'Lithuania' AS country_name, 'LTU' AS iso3_code, '440' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LU' AS country_code, 'Luxembourg' AS country_name, 'LUX' AS iso3_code, '442' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LV' AS country_code, 'Latvia' AS country_name, 'LVA' AS iso3_code, '428' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'LY' AS country_code, 'Libya' AS country_name, 'LBY' AS iso3_code, '434' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MA' AS country_code, 'Morocco' AS country_name, 'MAR' AS iso3_code, '504' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MC' AS country_code, 'Monaco' AS country_name, 'MCO' AS iso3_code, '492' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MD' AS country_code, 'Moldova' AS country_name, 'MDA' AS iso3_code, '498' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ME' AS country_code, 'Montenegro' AS country_name, 'MNE' AS iso3_code, '499' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MF' AS country_code, 'Saint Martin' AS country_name, 'MAF' AS iso3_code, '663' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MG' AS country_code, 'Madagascar' AS country_name, 'MDG' AS iso3_code, '450' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MH' AS country_code, 'Marshall Islands' AS country_name, 'MHL' AS iso3_code, '584' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MK' AS country_code, 'North Macedonia' AS country_name, 'MKD' AS iso3_code, '807' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ML' AS country_code, 'Mali' AS country_name, 'MLI' AS iso3_code, '466' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MM' AS country_code, 'Myanmar' AS country_name, 'MMR' AS iso3_code, '104' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MN' AS country_code, 'Mongolia' AS country_name, 'MNG' AS iso3_code, '496' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MO' AS country_code, 'Macao' AS country_name, 'MAC' AS iso3_code, '446' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MP' AS country_code, 'Northern Mariana Islands' AS country_name, 'MNP' AS iso3_code, '580' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MQ' AS country_code, 'Martinique' AS country_name, 'MTQ' AS iso3_code, '474' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MR' AS country_code, 'Mauritania' AS country_name, 'MRT' AS iso3_code, '478' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MS' AS country_code, 'Montserrat' AS country_name, 'MSR' AS iso3_code, '500' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MT' AS country_code, 'Malta' AS country_name, 'MLT' AS iso3_code, '470' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MU' AS country_code, 'Mauritius' AS country_name, 'MUS' AS iso3_code, '480' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MV' AS country_code, 'Maldives' AS country_name, 'MDV' AS iso3_code, '462' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MW' AS country_code, 'Malawi' AS country_name, 'MWI' AS iso3_code, '454' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MX' AS country_code, 'Mexico' AS country_name, 'MEX' AS iso3_code, '484' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MY' AS country_code, 'Malaysia' AS country_name, 'MYS' AS iso3_code, '458' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'MZ' AS country_code, 'Mozambique' AS country_name, 'MOZ' AS iso3_code, '508' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NA' AS country_code, 'Namibia' AS country_name, 'NAM' AS iso3_code, '516' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NC' AS country_code, 'New Caledonia' AS country_name, 'NCL' AS iso3_code, '540' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NE' AS country_code, 'Niger' AS country_name, 'NER' AS iso3_code, '562' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NF' AS country_code, 'Norfolk Island' AS country_name, 'NFK' AS iso3_code, '574' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NG' AS country_code, 'Nigeria' AS country_name, 'NGA' AS iso3_code, '566' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NI' AS country_code, 'Nicaragua' AS country_name, 'NIC' AS iso3_code, '558' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NL' AS country_code, 'Netherlands' AS country_name, 'NLD' AS iso3_code, '528' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NO' AS country_code, 'Norway' AS country_name, 'NOR' AS iso3_code, '578' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NP' AS country_code, 'Nepal' AS country_name, 'NPL' AS iso3_code, '524' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NR' AS country_code, 'Nauru' AS country_name, 'NRU' AS iso3_code, '520' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NU' AS country_code, 'Niue' AS country_name, 'NIU' AS iso3_code, '570' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'NZ' AS country_code, 'New Zealand' AS country_name, 'NZL' AS iso3_code, '554' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'OM' AS country_code, 'Oman' AS country_name, 'OMN' AS iso3_code, '512' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PA' AS country_code, 'Panama' AS country_name, 'PAN' AS iso3_code, '591' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PE' AS country_code, 'Peru' AS country_name, 'PER' AS iso3_code, '604' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PF' AS country_code, 'French Polynesia' AS country_name, 'PYF' AS iso3_code, '258' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PG' AS country_code, 'Papua New Guinea' AS country_name, 'PNG' AS iso3_code, '598' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PH' AS country_code, 'Philippines' AS country_name, 'PHL' AS iso3_code, '608' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PK' AS country_code, 'Pakistan' AS country_name, 'PAK' AS iso3_code, '586' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PL' AS country_code, 'Poland' AS country_name, 'POL' AS iso3_code, '616' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PM' AS country_code, 'Saint Pierre and Miquelon' AS country_name, 'SPM' AS iso3_code, '666' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PN' AS country_code, 'Pitcairn' AS country_name, 'PCN' AS iso3_code, '612' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PR' AS country_code, 'Puerto Rico' AS country_name, 'PRI' AS iso3_code, '630' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PS' AS country_code, 'Palestine, State of' AS country_name, 'PSE' AS iso3_code, '275' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PT' AS country_code, 'Portugal' AS country_name, 'PRT' AS iso3_code, '620' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PW' AS country_code, 'Palau' AS country_name, 'PLW' AS iso3_code, '585' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'PY' AS country_code, 'Paraguay' AS country_name, 'PRY' AS iso3_code, '600' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'QA' AS country_code, 'Qatar' AS country_name, 'QAT' AS iso3_code, '634' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'RE' AS country_code, 'Reunion' AS country_name, 'REU' AS iso3_code, '638' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'RO' AS country_code, 'Romania' AS country_name, 'ROU' AS iso3_code, '642' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'RS' AS country_code, 'Serbia' AS country_name, 'SRB' AS iso3_code, '688' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'RU' AS country_code, 'Russian Federation' AS country_name, 'RUS' AS iso3_code, '643' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'RW' AS country_code, 'Rwanda' AS country_name, 'RWA' AS iso3_code, '646' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SA' AS country_code, 'Saudi Arabia' AS country_name, 'SAU' AS iso3_code, '682' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SB' AS country_code, 'Solomon Islands' AS country_name, 'SLB' AS iso3_code, '090' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SC' AS country_code, 'Seychelles' AS country_name, 'SYC' AS iso3_code, '690' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SD' AS country_code, 'Sudan' AS country_name, 'SDN' AS iso3_code, '729' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SE' AS country_code, 'Sweden' AS country_name, 'SWE' AS iso3_code, '752' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SG' AS country_code, 'Singapore' AS country_name, 'SGP' AS iso3_code, '702' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SH' AS country_code, 'Saint Helena' AS country_name, 'SHN' AS iso3_code, '654' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SI' AS country_code, 'Slovenia' AS country_name, 'SVN' AS iso3_code, '705' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SJ' AS country_code, 'Svalbard and Jan Mayen' AS country_name, 'SJM' AS iso3_code, '744' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SK' AS country_code, 'Slovakia' AS country_name, 'SVK' AS iso3_code, '703' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SL' AS country_code, 'Sierra Leone' AS country_name, 'SLE' AS iso3_code, '694' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SM' AS country_code, 'San Marino' AS country_name, 'SMR' AS iso3_code, '674' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SN' AS country_code, 'Senegal' AS country_name, 'SEN' AS iso3_code, '686' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SO' AS country_code, 'Somalia' AS country_name, 'SOM' AS iso3_code, '706' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SR' AS country_code, 'Suriname' AS country_name, 'SUR' AS iso3_code, '740' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SS' AS country_code, 'South Sudan' AS country_name, 'SSD' AS iso3_code, '728' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ST' AS country_code, 'Sao Tome and Principe' AS country_name, 'STP' AS iso3_code, '678' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SV' AS country_code, 'El Salvador' AS country_name, 'SLV' AS iso3_code, '222' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SX' AS country_code, 'Sint Maarten' AS country_name, 'SXM' AS iso3_code, '534' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SY' AS country_code, 'Syrian Arab Republic' AS country_name, 'SYR' AS iso3_code, '760' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'SZ' AS country_code, 'Eswatini' AS country_name, 'SWZ' AS iso3_code, '748' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TC' AS country_code, 'Turks and Caicos Islands' AS country_name, 'TCA' AS iso3_code, '796' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TD' AS country_code, 'Chad' AS country_name, 'TCD' AS iso3_code, '148' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TF' AS country_code, 'French Southern Territories' AS country_name, 'ATF' AS iso3_code, '260' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TG' AS country_code, 'Togo' AS country_name, 'TGO' AS iso3_code, '768' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TH' AS country_code, 'Thailand' AS country_name, 'THA' AS iso3_code, '764' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TJ' AS country_code, 'Tajikistan' AS country_name, 'TJK' AS iso3_code, '762' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TK' AS country_code, 'Tokelau' AS country_name, 'TKL' AS iso3_code, '772' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TL' AS country_code, 'Timor-Leste' AS country_name, 'TLS' AS iso3_code, '626' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TM' AS country_code, 'Turkmenistan' AS country_name, 'TKM' AS iso3_code, '795' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TN' AS country_code, 'Tunisia' AS country_name, 'TUN' AS iso3_code, '788' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TO' AS country_code, 'Tonga' AS country_name, 'TON' AS iso3_code, '776' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TR' AS country_code, 'Turkey' AS country_name, 'TUR' AS iso3_code, '792' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TT' AS country_code, 'Trinidad and Tobago' AS country_name, 'TTO' AS iso3_code, '780' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TV' AS country_code, 'Tuvalu' AS country_name, 'TUV' AS iso3_code, '798' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TW' AS country_code, 'Taiwan' AS country_name, 'TWN' AS iso3_code, '158' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'TZ' AS country_code, 'Tanzania' AS country_name, 'TZA' AS iso3_code, '834' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'UA' AS country_code, 'Ukraine' AS country_name, 'UKR' AS iso3_code, '804' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'UG' AS country_code, 'Uganda' AS country_name, 'UGA' AS iso3_code, '800' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'UM' AS country_code, 'United States Minor Outlying Islands' AS country_name, 'UMI' AS iso3_code, '581' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'US' AS country_code, 'United States' AS country_name, 'USA' AS iso3_code, '840' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'UY' AS country_code, 'Uruguay' AS country_name, 'URY' AS iso3_code, '858' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'UZ' AS country_code, 'Uzbekistan' AS country_name, 'UZB' AS iso3_code, '860' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VA' AS country_code, 'Holy See (Vatican City State)' AS country_name, 'VAT' AS iso3_code, '336' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VC' AS country_code, 'Saint Vincent and the Grenadines' AS country_name, 'VCT' AS iso3_code, '670' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VE' AS country_code, 'Venezuela' AS country_name, 'VEN' AS iso3_code, '862' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VG' AS country_code, 'Virgin Islands, British' AS country_name, 'VGB' AS iso3_code, '092' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VI' AS country_code, 'Virgin Islands, U.S.' AS country_name, 'VIR' AS iso3_code, '850' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VN' AS country_code, 'Viet Nam' AS country_name, 'VNM' AS iso3_code, '704' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'VU' AS country_code, 'Vanuatu' AS country_name, 'VUT' AS iso3_code, '548' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'WF' AS country_code, 'Wallis and Futuna' AS country_name, 'WLF' AS iso3_code, '876' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'WS' AS country_code, 'Samoa' AS country_name, 'WSM' AS iso3_code, '882' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'YE' AS country_code, 'Yemen' AS country_name, 'YEM' AS iso3_code, '887' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'YT' AS country_code, 'Mayotte' AS country_name, 'MYT' AS iso3_code, '175' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ZA' AS country_code, 'South Africa' AS country_name, 'ZAF' AS iso3_code, '710' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ZM' AS country_code, 'Zambia' AS country_name, 'ZMB' AS iso3_code, '894' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  MERGE INTO country_ref t
  USING (SELECT 'ZW' AS country_code, 'Zimbabwe' AS country_name, 'ZWE' AS iso3_code, '716' AS num_code FROM dual) s
  ON (t.country_code = s.country_code)
  WHEN MATCHED THEN UPDATE SET t.country_name = s.country_name, t.iso3_code = s.iso3_code, t.num_code = s.num_code, t.active = 'Y', t.updated_at = SYSTIMESTAMP
  WHEN NOT MATCHED THEN INSERT (country_code, country_name, iso3_code, num_code, active, created_at, updated_at)
  VALUES (s.country_code, s.country_name, s.iso3_code, s.num_code, 'Y', SYSTIMESTAMP, SYSTIMESTAMP);
  COMMIT;
END;
/
