-- From:
-- https://stackoverflow.com/questions/8092086/create-postgresql-role-user-if-it-doesnt-exist

DO $$
DECLARE
  role_record RECORD;
  col_name VARCHAR;
BEGIN
   SELECT INTO role_record *
     FROM pg_catalog.pg_roles
     WHERE rolname = 'web_app';

   IF NOT FOUND THEN
     RAISE EXCEPTION 'web_app ROLE needs to be created: CREATE USER web_app WITH NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE ;';
   END IF;

   FOR col_name IN
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'pg_catalog' AND table_name = 'pg_roles'
   LOOP

    CASE col_name
    WHEN 'rolname', 'rolsuper', 'rolinherit', 'rolcreaterole', 'rolcreatedb',
      'rolcanlogin', 'rolreplication', 'rolbypassrls',
      'rolconnlimit', 'rolpassword', 'rolvaliduntil', 'rolconfig', 'oid' THEN
      CONTINUE;
    ELSE
      RAISE EXCEPTION 'UNKNOWN value for ROLE web_app: %', col_name;
    END CASE;

    CASE

    WHEN col_name = 'rolname' AND role_record.rolname = 'web_app' THEN
      CONTINUE;

    WHEN col_name = 'rolsuper' AND role_record.rolsuper = FALSE THEN
      CONTINUE;

    WHEN col_name = 'rolinherit' AND role_record.rolinherit = FALSE THEN
      CONTINUE;

    WHEN col_name = 'rolcreaterole' AND role_record.rolcreaterole = FALSE THEN
      CONTINUE;

    when col_name = 'rolcreatedb' AND role_record.rolcreatedb = FALSE THEN
      CONTINUE;

    when col_name = 'rolcanlogin' AND role_record.rolcanlogin = TRUE THEN
      CONTINUE;

    WHEN col_name = 'rolreplication' AND role_record.rolreplication = FALSE THEN
      CONTINUE;

    WHEN col_name = 'rolbypassrls' AND role_record.rolbypassrls = FALSE THEN
      CONTINUE;

    ELSE
      RAISE EXCEPTION 'INVALID VALUE value for ROLE web_app: %', col_name;
    END CASE;
   END LOOP;
END
$$;
