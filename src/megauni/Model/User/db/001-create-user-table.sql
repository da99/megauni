
-- DOWN
-- DROP TABLE IF EXISTS `user`;

-- UP
DO $$
  DECLARE
    col RECORD;
  BEGIN
    CREATE TABLE IF NOT EXISTS "user" (
      id                   BIGSERIAL PRIMARY KEY,
      pswd_hash            BYTEA NOT NULL,
      created_at           timestamptz NOT NULL DEFAULT NOW()
    );

    FOR col IN
	    SELECT *
	    FROM information_schema.columns
	    WHERE  table_catalog = 'megauni_db' AND table_name = 'user'
    LOOP

      IF col.column_name = 'id' AND
        col.column_default = 'nextval(''user_id_seq''::regclass)' AND
        col.is_nullable = 'NO' AND
        col.data_type = 'bigint'
        THEN
        CONTINUE;
      END IF;

      IF col.column_name = 'pswd_hash' AND
        col.column_default IS NULL AND
        col.is_nullable = 'NO' AND
        col.data_type = 'bytea'
        THEN
        CONTINUE;
      END IF;

      IF col.column_name = 'created_at' AND
        col.column_default = 'now()' AND
        col.is_nullable = 'NO' AND
        col.data_type = 'timestamp with time zone' AND
        col.datetime_precision = 6
        THEN
        CONTINUE;
      END IF;

      RAISE EXCEPTION 'Invalid definition for column: user.%', col.column_name;
    END LOOP;


  END
$$;


