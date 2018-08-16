
-- www_definer role is used for "SECURITY DEFINER"
-- functions. This helps to limit the privilege escalation
-- instead of using the db owner.

-- RUN: -----------------------

BEGIN;

  CREATE ROLE www_definer
  NOSUPERUSER
  NOCREATEDB
  NOCREATEROLE
  NOBYPASSRLS
  NOINHERIT
  NOLOGIN
  NOREPLICATION;

COMMIT;

-- ALWAYS RUN: --------
