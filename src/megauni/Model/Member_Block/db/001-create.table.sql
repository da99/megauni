
CREATE TABLE IF NOT EXISTS "member_block" (
  id                   BIGSERIAL PRIMARY KEY,
  screen_name_id       BIGINT NOT NULL,
  member_id            BIGINT NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT NOW()
);
