

BEGIN;
  ALTER ROLE www_app WITH INHERIT LOGIN CONNECTION LIMIT 3;
  GRANT www_group TO www_app;
COMMIT;



