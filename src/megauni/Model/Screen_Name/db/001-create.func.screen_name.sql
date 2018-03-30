
CREATE OR REPLACE FUNCTION screen_name(
  IN raw_view_id BIGINT, -- screen name
  IN raw_screen_name VARCHAR
)
RETURNS TABLE (id BIGINT, screen_name VARCHAR) AS $$
DECLARE

BEGIN
  RETURN QUERY
  SELECT sn.id, sn.screen_name
  FROM screen_name sn
  WHERE sn.screen_name = screen_name_canonical(raw_screen_name);
END
$$ LANGUAGE plpgsql;
