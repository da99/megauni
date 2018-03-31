
CREATE OR REPLACE FUNCTION message_receive_command_insert(
  IN  owner_id          message_receive_command.id%TYPE, -- screen name id
  IN  raw_sender        VARCHAR, -- screen name
  IN  raw_folder_source VARCHAR,
  IN  raw_folder_dest   VARCHAR
)
RETURNS TABLE(
  id               message_receive_command.id%TYPE,
  source_folder_id message_receive_command.source_folder_id%TYPE,
  dest_folder_id   message_receive_command.dest_folder_id%TYPE
)
AS $$
DECLARE
  sender        RECORD;
  source_folder RECORD;
  dest_folder   RECORD;
BEGIN
  sender        := screen_name(owner_id, raw_sender);
  source_folder := message_folder(owner_id, sender.screen_name, raw_folder_source);
  dest_folder   := message_folder_insert(owner_id, raw_folder_dest);

  RETURN QUERY
  INSERT INTO
  message_receive_command AS mrc ("id", "owner_id", "sender_id", "source_folder_id", "dest_folder_id")
  VALUES (DEFAULT, owner_id, sender.id, source_folder.id, dest_folder.id)
  RETURNING mrc.id, mrc.source_folder_id, mrc.dest_folder_id;
END
$$ LANGUAGE plpgsql;
