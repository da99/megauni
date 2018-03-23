

CREATE TABLE IF NOT EXISTS "screen_name" (

  id          BIGSERIAL                PRIMARY KEY,
  owner_id    BIGINT                   NOT NULL, -- Refers to "user" id:
  privacy     SMALLINT                 NOT NULL DEFAULT 0,

  screen_name VARCHAR(30)              NOT NULL
  UNIQUE CHECK(screen_name = clean_new_screen_name(screen_name)),

  nick_name   VARCHAR(30)              NULL,
  created_at  timestamptz NOT NULL DEFAULT NOW(),
  trashed_at  timestamp                NULL
) ;

