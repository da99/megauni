

SET ROLE db_owner;


CREATE TABLE "screen_name" (

  id            BIGSERIAL     PRIMARY KEY,
  owner_id      BIGINT        NOT NULL, -- Refers to "Member" id or screen_name id
  owner_type_id object_type   NOT NULL,
  privacy       privacy_level NOT NULL DEFAULT 'me_only',

  screen_name VARCHAR(30)              NOT NULL
  UNIQUE CHECK(screen_name = clean_new_screen_name(screen_name)),

  nick_name   VARCHAR(30)              NULL,
  created_at  timestamptz NOT NULL DEFAULT NOW(),
  trashed_at  timestamp                NULL

);

COMMIT;
