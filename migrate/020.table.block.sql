
SET ROLE db_owner;

CREATE TABLE "block" (
  id                   BIGSERIAL PRIMARY KEY,
  screen_name_id       BIGINT NOT NULL,
  member_id            BIGINT NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT NOW()
);

COMMIT;
