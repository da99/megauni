

CREATE TABLE IF NOT EXISTS "screen_name" (

  id             BIGSERIAL PRIMARY KEY,

  owner_id       BIGINT NOT NULL, -- Refers to "user" id:

  privacy        SMALLINT NOT NULL,

  parent_id      BIGINT  NOT NULL DEFAULT 0, -- Refers to "screen_name" id. 0 == top level:

  screen_name    VARCHAR(30)    NOT NULL,
  CONSTRAINT     "screen_name_unique_idx" UNIQUE(parent_id, screen_name),

  nick_name      VARCHAR(30) NULL,

  created_at     timestamp,
  trashed_at     timestamp NULL

) ;

