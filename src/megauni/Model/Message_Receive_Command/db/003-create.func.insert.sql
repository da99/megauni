
CREATE OR REPLACE FUNCTION message_receive_command_insert(
  IN  owner_id          BIGINT, -- screen name id
  IN  raw_sender        VARCHAR, -- screen name
  IN  raw_folder_source VARCHAR,
  IN  raw_folder_dest   VARCHAR
)
RETURNS TABLE(
  id BIGINT,
  folder_id_source BIGINT,
  folder_id_dest BIGINT
)
AS $$
DECLARE
  source_folder RECORD;
  dest_folder   RECORD;
  sender        RECORD;
BEGIN
  sender        := screen_name(owner_id, raw_sender);
  source_folder := message_folder(owner_id, sender.screen_name, raw_folder_source);
  dest_folder   := message_folder_insert(owner_id, raw_folder_dest);

  RETURN QUERY
  INSERT INTO
  message_receive_command AS mrc ("id", "owner_id", "sender_id", "folder_id_source", "folder_id_dest")
  VALUES (DEFAULT, owner_id, sender.id, source_folder.id, dest_folder.id)
  RETURNING mrc.id, mrc.folder_id_source, mrc.folder_id_dest;
END
$$ LANGUAGE plpgsql;
