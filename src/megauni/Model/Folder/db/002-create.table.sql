
CREATE TABLE IF NOT EXISTS "message_folder" (

  id       BIGSERIAL   PRIMARY KEY,
  owner_id BIGINT      NOT NULL, -- refers to screen_name id
  type_id  SMALLINT    NOT NULL, -- e.g. type_id('Message'), type_id('Contact')
  name     VARCHAR(30) NOT NULL
  CHECK(name = clean_new_message_folder(name))

);
