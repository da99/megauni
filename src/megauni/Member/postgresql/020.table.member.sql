
SET ROLE db_owner;


CREATE TABLE "member" (
  id                   BIGSERIAL PRIMARY KEY,
  pswd_hash            BYTEA NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT NOW()
);
COMMIT;
