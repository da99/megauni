
SET ROLE db_owner;

CREATE TABLE "comment_permit" (
  id                   BIGSERIAL PRIMARY KEY,
  active               BOOLEAN DEFAULT true,
  type_id              comment_permit_type,
  comment_id           BIGINT NOT NULL,
  grantor_id           BIGINT NOT NULL, -- screen_name id
  holder_id            BIGINT NOT NULL, -- screen_name id
  created_at           timestamptz NOT NULL DEFAULT NOW()
);

COMMIT;
