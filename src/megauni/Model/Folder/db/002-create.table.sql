
CREATE TABLE IF NOT EXISTS "message_folder" (

  id               BIGSERIAL   PRIMARY KEY,
  owner_id         BIGINT      NOT NULL, -- refers to member or screen_name id
  owner_type_id    SMALLINT    NOT NULL, -- type_id('Member') || type_id('Screen_Name')
  name             VARCHAR(30) NOT NULL
  CHECK(name = clean_new_message_folder(UPPER(name))),
  display_name     VARCHAR(30) NOT NULL
  CHECK(name = clean_new_message_folder(name) AND UPPER(display_name) = name),
  UNIQUE (owner_id, owner_type_id, name)

);
