
CREATE TABLE IF NOT EXISTS "message_receive_command" (
  id                BIGSERIAL PRIMARY KEY,
  owner_id          BIGINT    NOT NULL, -- refers to member or screen_name id
  sender_id         BIGINT    NOT NULL, -- screen_name id
  message_type_id   SMALLINT  NOT NULL,
  message_folder_id BIGINT    NOT NULL,

  -- Ensure there is only one command for each message type:
  UNIQUE (owner_id, sender_id, message_type_id)
);
