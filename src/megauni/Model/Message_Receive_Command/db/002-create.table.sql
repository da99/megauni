
CREATE TABLE IF NOT EXISTS "message_receive_command" (
  id               BIGSERIAL PRIMARY KEY,
  owner_id         BIGINT    NOT NULL, -- refers to member or screen_name id
  sender_id        BIGINT    NOT NULL, -- screen_name id
  folder_id_source BIGINT    NOT NULL, -- message_folder_id
  folder_id_dest   BIGINT    NOT NULL, -- message_folder_id

  -- Ensure there is only one command for each message type:
  UNIQUE (owner_id, sender_id, folder_id_source)
);
