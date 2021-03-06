
SET ROLE screen_name_definer;

CREATE TABLE screen_name.tbl (

  id            BIGSERIAL     PRIMARY KEY,
  owner_id      BIGINT        NOT NULL, -- Refers to "Member" id or screen_name id
  owner_type_id base.object_type   NOT NULL,
  privacy       base.privacy_level NOT NULL DEFAULT 'me_only',

  screen_name VARCHAR(30)              NOT NULL
  UNIQUE CHECK(screen_name = screen_name.clean_new(screen_name)),

  nick_name   VARCHAR(30)              NULL,
  created_at  timestamptz NOT NULL DEFAULT NOW(),
  trashed_at  timestamp                NULL

);

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON screen_name.tbl TO screen_name_definer;

GRANT USAGE, SELECT
ON screen_name.tbl_id_seq TO screen_name_definer;

COMMIT;
