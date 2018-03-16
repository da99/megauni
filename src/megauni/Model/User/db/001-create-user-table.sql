
-- DOWN
-- DROP TABLE IF EXISTS `user`;

-- UP
CREATE TABLE IF NOT EXISTS "user" (
  id                   BIGSERIAL PRIMARY KEY,

  -- Bcrypt-ed string storage requirements: https://mariadb.com/kb/en/mariadb/data-type-storage-requirements/
  pswd_hash            BYTEA NOT NULL,

  created_at           timestamptz NOT NULL DEFAULT NOW()
);



