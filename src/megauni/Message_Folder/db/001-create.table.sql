
CREATE TABLE IF NOT EXISTS "message_folder" (

  id            BIGSERIAL   PRIMARY KEY,
  owner_id      BIGINT      NOT NULL, -- refers to member or screen_name id
  name          VARCHAR(30) NOT NULL CHECK(name = message_folder_canonical(UPPER(name))),
  display_name  VARCHAR(30) NOT NULL CHECK(name = message_folder_canonical(name) AND UPPER(display_name) = name),
  created_at    timestamptz NOT NULL DEFAULT NOW(),

  UNIQUE (owner_id, name)
);
