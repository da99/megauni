
CREATE TABLE IF NOT EXISTS "message_folder" (

  id       BIGSERIAL   PRIMARY KEY,
  owner_id BIGINT      NOT NULL, -- refers to screen_name id
  name     VARCHAR(30) NOT NULL
  CHECK(name = clean_new_message_folder(name))

);
