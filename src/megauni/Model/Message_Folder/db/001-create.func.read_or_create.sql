
CREATE OR REPLACE FUNCTION message_folder_id_create(
  IN raw_owner_id BIGINT,
  IN raw_name VARCHAR
) RETURNS BIGINT
AS $$
DECLARE
  the_id BIGINT;
  canonical_name VARCHAR;
BEGIN
  canonical_name := message_folder_canonical(raw_name);
  SELECT id
  into the_id
  FROM message_folder
  WHERE "owner_id" = raw_owner_id AND name = canonical_name;

  IF NOT FOUND THEN
    INSERT INTO message_folder ("id", "owner_id", "name")
    VALUES (DEFAULT, raw_owner_id, canonical_name)
    RETURNING "id" INTO the_id;
  END IF;

  RETURN the_id;
END
$$
LANGUAGE plpgsql;
