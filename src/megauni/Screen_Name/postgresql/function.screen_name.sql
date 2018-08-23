
SET ROLE www_definer;

CREATE OR REPLACE FUNCTION screen_name(
  IN raw_screen_name VARCHAR
)
RETURNS TABLE (
  id          screen_name.screen_name.id%TYPE,
  owner_id    screen_name.screen_name.owner_id%TYPE,
  screen_name screen_name.screen_name.screen_name%TYPE
) AS $$
DECLARE

BEGIN
  RETURN QUERY
  SELECT
  sn.id AS id,
  sn.owner_id AS owner_id,
  sn.screen_name AS screen_name
  FROM screen_name sn
  WHERE sn.screen_name = screen_name.canonical(raw_screen_name)
  AND sn.owner_type_id = 'member'
  ;
END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

-- GRANT EXECUTE ON FUNCTION screen_name(varchar) TO www_group ;
COMMIT;
