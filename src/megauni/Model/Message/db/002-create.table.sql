
CREATE TABLE IF NOT EXISTS "message" (
  id         BIGSERIAL PRIMARY KEY,
  status_id  SMALLINT  NOT NULL DEFAULT type_id('Draft'),
  owner_id   BIGINT    NOT NULL, -- refers to screen_name id
  title      VARCHAR(140),
  body       TEXT,
  created_at timestamptz NOT NULL DEFAULT NOW()
);
