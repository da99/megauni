
CREATE UNIQUE INDEX IF NOT EXISTS message_folder_name_unique_idx
ON message_folder (UPPER(name));
