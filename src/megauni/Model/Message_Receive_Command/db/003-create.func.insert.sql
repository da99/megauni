
CREATE OR REPLACE FUNCTION message_receive_command_insert(
  IN  owner_id                   BIGINT, -- screen name id
  IN  sender_id                  BIGINT, -- screen name id
  IN  message_type               VARCHAR,
  IN  folder                     VARCHAR,

  OUT id                BIGINT,
  OUT message_type_id   SMALLINT,
  OUT message_folder_id SMALLINT
)
AS $$
  DECLARE
  temp RECORD;
  BEGIN
    message_type_id   := message_type_id_create(sender_id, message_type);
    message_folder_id := message_folder_id_create(owner_id, folder);

    INSERT INTO message_receive_command ("id", "owner_id", "sender_id", "message_type_id", "message_folder_id")
    VALUES (DEFAULT, owner_id, sender_id, message_type_id, message_folder_id)
    RETURNING "id" INTO id;
  END
$$ LANGUAGE plpgsql;
