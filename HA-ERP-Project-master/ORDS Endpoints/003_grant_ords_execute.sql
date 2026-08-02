-- First confirm you're in the right schema
SELECT USER FROM dual;

-- Then check if the grant actually landed
SELECT grantee, table_name, privilege
FROM all_tab_privs
WHERE table_name = 'SUPPLIER_AUTH_PKG'
AND privilege = 'EXECUTE';

-- =============================================================================
-- 003_grant_ords_execute.sql
-- Fix ORDS 403: "function referenced by SQL is not accessible"
--
-- ORDS executes SQL/PLSQL as a low-privilege database user (the ORDS runtime
-- user, often ORDS_PUBLIC_USER or the REST-enabled schema user). That user
-- can see your tables/views via the schema but cannot EXECUTE your packages
-- unless explicitly granted.
--
-- Run this as the OWNER of the packages (the same schema that owns
-- supplier_auth_pkg, supplier_request_pkg, etc.) — i.e. the same user
-- you ran 001 and the package bodies as.
-- =============================================================================

-- Replace HA_ERP_API with your actual schema name if different.
-- The ORDS runtime user varies; on ATP the REST-enabled schema executes
-- as itself, so granting to PUBLIC covers all ORDS callers safely for
-- internal packages. If you prefer tighter control, grant to the specific
-- ORDS runtime user instead of PUBLIC.

GRANT EXECUTE ON supplier_auth_pkg       TO PUBLIC;
GRANT EXECUTE ON supplier_config_pkg     TO PUBLIC;
GRANT EXECUTE ON supplier_dashboard_pkg  TO PUBLIC;
GRANT EXECUTE ON supplier_integration_pkg TO PUBLIC;
GRANT EXECUTE ON supplier_projection_pkg TO PUBLIC;
GRANT EXECUTE ON supplier_request_pkg    TO PUBLIC;
GRANT EXECUTE ON supplier_review_pkg     TO PUBLIC;
GRANT EXECUTE ON supplier_validation_pkg TO PUBLIC;
GRANT EXECUTE ON supplier_workflow_pkg   TO PUBLIC;

-- Also grant SELECT on the views used in ORDS handlers
-- (if ORDS is running as a different schema these are needed too)
GRANT SELECT ON request_dashboard_v          TO PUBLIC;
GRANT SELECT ON request_detail_safe_v        TO PUBLIC;
GRANT SELECT ON integration_log_safe_v       TO PUBLIC;
GRANT SELECT ON risk_rule_config_v           TO PUBLIC;
GRANT SELECT ON high_risk_country_config_v   TO PUBLIC;
GRANT SELECT ON action_history               TO PUBLIC;
GRANT SELECT ON supplier_request             TO PUBLIC;

-- If you would rather grant to the specific ORDS user instead of PUBLIC,
-- first find it with:
--   SELECT username FROM all_users WHERE username LIKE '%ORDS%' OR username LIKE '%REST%';
-- Then replace TO PUBLIC with TO <that_username> on each line above.

COMMIT;
