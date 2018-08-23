
SET ROLE db_owner;

CREATE TABLE "conversation_comment" (
  id              BIGSERIAL     PRIMARY KEY,
  privacy         privacy_level NOT NULL DEFAULT 'private',
  conversation_id BIGINT        NOT NULL,
  author_id       BIGINT        NOT NULL,
  body            TEXT,
  created_at      timestamptz   NOT NULL DEFAULT NOW()
);
COMMIT;
