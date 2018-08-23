
SET ROLE db_owner;


CREATE TABLE member.tbl (
  id                   BIGSERIAL PRIMARY KEY,
  pswd_hash            BYTEA NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT NOW()
);

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON member.tbl TO member_definer;

GRANT USAGE, SELECT
ON member.tbl_id_seq TO member_definer;
COMMIT;
