

CREATE TABLE IF NOT EXISTS "screen_name" (

  id          BIGSERIAL                PRIMARY KEY,
  owner_id    BIGINT                   NOT NULL, -- Refers to "Member" id or screen_name id
  owner_type_id SMALLINT               NOT NULL, -- type_id("Member") || type_id("Screen_Name")
  privacy     SMALLINT                 NOT NULL DEFAULT privacy_id('ME ONLY'),

  screen_name VARCHAR(30)              NOT NULL
  UNIQUE CHECK(screen_name = clean_new_screen_name(screen_name)),

  nick_name   VARCHAR(30)              NULL,
  created_at  timestamptz NOT NULL DEFAULT NOW(),
  trashed_at  timestamp                NULL

);

