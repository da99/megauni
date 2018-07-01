
CREATE OR REPLACE FUNCTION screen_name(
  IN raw_view_id screen_name.id%TYPE, -- screen name
  IN raw_screen_name VARCHAR
)
RETURNS TABLE (
  id          screen_name.id%TYPE,
  screen_name screen_name.screen_name%TYPE
) AS $$
DECLARE

BEGIN
  RETURN QUERY
  SELECT sn.id AS id, sn.screen_name AS screen_name
  FROM screen_name sn
  WHERE sn.screen_name = screen_name_canonical(raw_screen_name);
END
$$ LANGUAGE plpgsql;
COMMIT;
