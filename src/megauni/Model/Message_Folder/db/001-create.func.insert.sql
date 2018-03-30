
CREATE OR REPLACE FUNCTION message_folder_insert(
  IN  raw_owner_id BIGINT,
  IN  raw_name     VARCHAR
)
RETURNS TABLE("id" BIGINT, "name" VARCHAR, "display_name" VARCHAR)
AS $$
DECLARE
  temp_rec RECORD;
  canonical_name VARCHAR;
BEGIN

  canonical_name := message_folder_canonical(raw_name);

  RETURN QUERY
  SELECT mf.id, mf.name, mf.display_name
  FROM message_folder AS mf
  WHERE mf.owner_id = raw_owner_id AND mf.name = canonical_name;

  IF NOT FOUND THEN
    RETURN QUERY
    INSERT INTO
    "message_folder" AS mf ( "id", "owner_id", "name", "display_name" )
    VALUES (DEFAULT, raw_owner_id, UPPER(canonical_name), canonical_name)
    RETURNING mf.id, mf.name, mf.display_name;
  END IF;

END
$$
LANGUAGE plpgsql;
