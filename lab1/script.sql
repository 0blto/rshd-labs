SET myvars.table_name TO :table_name;
SET myvars.schema_name TO :schema_name;


DO $$
   DECLARE
       trigger_record RECORD;
       table_name varchar(128) := current_setting('myvars.table_name');
       schema_name varchar(128) := current_setting('myvars.schema_name');
   BEGIN
        RAISE NOTICE '|----------------------------------------|----------------------------------------|';
        RAISE NOTICE '|%|%|', LPAD('TRIGGER_NAME', 40), LPAD('COLUMN_NAME', 40);
        RAISE NOTICE '|----------------------------------------|----------------------------------------|';
        FOR trigger_record IN
        EXECUTE '
            SELECT
                t.tgname AS trigger_name,
                c.relname AS table_name,
                a.attname AS column_name
            FROM
                pg_trigger t
                JOIN pg_class c ON t.tgrelid = c.oid
                LEFT JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ANY(t.tgattr)
                JOIN pg_namespace nsp ON nsp.oid=c.relnamespace
            WHERE
                c.relname=$1 AND nsp.nspname=$2
        ' USING table_name, schema_name
    LOOP
        RAISE NOTICE '|%|%|', LPAD(trigger_record.trigger_name, 40), LPAD(COALESCE(trigger_record.column_name, 'Вся таблица'), 40);
    END LOOP;
    RAISE NOTICE '|----------------------------------------|----------------------------------------|';
END $$;

