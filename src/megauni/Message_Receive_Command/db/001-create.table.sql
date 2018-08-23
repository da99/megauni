
CREATE TABLE IF NOT EXISTS "message_receive_command" (
  id               BIGSERIAL PRIMARY KEY,
  owner_id         BIGINT    NOT NULL, -- refers to member or screen_name id
  sender_id        BIGINT    NOT NULL, -- screen_name id
  source_folder_id BIGINT    NOT NULL, -- message_folder_id
  dest_folder_id   BIGINT    NOT NULL, -- message_folder_id

  -- Ensure there is only one command for each message type:
  UNIQUE (owner_id, sender_id, source_folder_id)
);
