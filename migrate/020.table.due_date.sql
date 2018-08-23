
SET ROLE db_owner;

CREATE TABLE "due_date" (
  id                   BIGSERIAL PRIMARY KEY,
  post_id              BIGINT NOT NULL,
  author_id            BIGINT NOT NULL, -- screen_name id
  starts_at            timestamptz DEFAULT NULL,
  ends_at              timestamptz NOT NULL
);

COMMIT;
