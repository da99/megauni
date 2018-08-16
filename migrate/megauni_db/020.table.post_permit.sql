
SET ROLE db_owner;

CREATE TABLE "post_permit" (
  id                   BIGSERIAL PRIMARY KEY,
  active               BOOLEAN DEFAULT true,
  permit_type          post_permit_type,
  post_id              BIGINT NOT NULL,
  grantor_id           BIGINT NOT NULL, -- screen_name id
  holder_id            BIGINT NOT NULL, -- screen_name id
  created_at           timestamptz NOT NULL DEFAULT NOW()
);

COMMIT;
