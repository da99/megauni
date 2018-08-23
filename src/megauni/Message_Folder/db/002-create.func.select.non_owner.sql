
CREATE OR REPLACE FUNCTION message_folder(
  IN raw_viewer_id  screen_name.id%TYPE, -- screen name id
  IN raw_owner_name screen_name.screen_name%TYPE, -- screen name
  IN raw_name       VARCHAR
) RETURNS TABLE(
  id           message_folder.id%TYPE,
  name         message_folder.name%TYPE,
  display_name message_folder.display_name%TYPE
) AS $$
DECLARE
  canonical_name VARCHAR;
  owner          RECORD;
BEGIN
  canonical_name := message_folder_canonical(raw_name);
  owner          := screen_name(raw_viewer_id, raw_owner_name);

  RETURN QUERY
  SELECT mf.id, mf.name, mf.display_name
  FROM message_folder mf
  WHERE mf.owner_id = owner.id AND mf.name = canonical_name;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not found: message folder: %', raw_name;
  END IF;
END
$$ LANGUAGE plpgsql;
