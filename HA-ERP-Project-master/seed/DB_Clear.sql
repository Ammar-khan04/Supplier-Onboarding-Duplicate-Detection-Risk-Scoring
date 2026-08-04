-- Commit the changes to finalize the deletion
COMMIT;

BEGIN
    -- 1. Attempt to drop the ORDS modules using the correct DELETE_MODULE procedure
    BEGIN
        ORDS.DELETE_MODULE(p_module_name => 'ha_supplier_onboarding_v1');
        ORDS.DELETE_MODULE(p_module_name => 'ha_supplier_onboarding_v1');
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    -- 2. Dynamically drop all Schema Objects (Tables, Views, Packages, Sequences)
    FOR obj IN (
        SELECT object_name, object_type 
        FROM user_objects 
        WHERE object_type IN ('TABLE', 'VIEW', 'SEQUENCE', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'SYNONYM')
        -- Ensure we drop dependent objects like packages and views before tables
        ORDER BY CASE object_type 
                    WHEN 'PACKAGE' THEN 1 
                    WHEN 'VIEW' THEN 2 
                    WHEN 'SEQUENCE' THEN 3
                    WHEN 'TABLE' THEN 4
                    ELSE 5 END
    ) LOOP
        BEGIN
            IF obj.object_type = 'TABLE' THEN
                -- CASCADE CONSTRAINTS ensures foreign keys don't block the drop
                EXECUTE IMMEDIATE 'DROP TABLE "' || obj.object_name || '" CASCADE CONSTRAINTS';
            ELSE
                EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' "' || obj.object_name || '"';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                -- Ignore errors for objects that might have already been dropped via cascades
                NULL; 
        END;
    END LOOP;
END;
/

