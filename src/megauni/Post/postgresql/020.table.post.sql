
SET ROLE db_owner;

CREATE TABLE "post" (
  id          BIGSERIAL PRIMARY KEY,
  privacy     privacy_level NOT NULL DEFAULT 'me_only',
  activity_id BIGINT NOT NULL,
  author_id   BIGINT NOT NULL, -- screen_name id
  created_at  timestamptz NOT NULL DEFAULT NOW()
);

COMMIT;
