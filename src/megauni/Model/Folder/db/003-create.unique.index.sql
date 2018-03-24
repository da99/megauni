
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS message_folder_name_type_id_unique_idx
ON message_folder (UPPER(name), type_id);
