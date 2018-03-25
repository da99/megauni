
CREATE TABLE IF NOT EXISTS "message_receive_command" (
  id BIGSERIAL PRIMARY KEY,
  owner_id         BIGINT      NOT NULL, -- refers to member or screen_name id
  owner_type_id    SMALLINT    NOT NULL, -- type_id('Member') || type_id('Screen_Name')
  message_type_id  SMALLINT    NOT NULL,
  folder_id        BIGINT      NOT NULL,

  -- Ensure there is only one command for each message type:
  UNIQUE (owner_id, owner_type_id, message_type_id)
);
