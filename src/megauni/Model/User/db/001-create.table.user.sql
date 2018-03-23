

-- UP
CREATE TABLE IF NOT EXISTS "user" (
  id                   BIGSERIAL PRIMARY KEY,
  pswd_hash            BYTEA NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT NOW()
);
