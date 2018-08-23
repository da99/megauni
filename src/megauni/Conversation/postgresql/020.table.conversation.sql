

SET ROLE db_owner;

CREATE TABLE "conversation" (
  id         BIGSERIAL   PRIMARY KEY,
  author_id  BIGINT      NOT NULL, -- screen name id
  title      VARCHAR(180),
  body       TEXT,
  created_at timestamptz NOT NULL DEFAULT NOW()
);

COMMIT;
