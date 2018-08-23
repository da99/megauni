
SET ROLE www_definer;

CREATE OR REPLACE FUNCTION insert_screen_name(
  IN  owner_id           member.id%TYPE,
  IN  raw_screen_name    VARCHAR
) RETURNS TABLE(
  id          screen_name.id%TYPE,
  screen_name screen_name.screen_name%TYPE
) AS $$
  DECLARE
    new_screen_name_record RECORD;
    clean_screen_name VARCHAR;

  BEGIN
    clean_screen_name := screen_name.canonical(raw_screen_name);

    RETURN QUERY
    INSERT INTO
    screen_name (owner_id, owner_type_id, screen_name)
    VALUES (owner_id, 'member', clean_screen_name)
    RETURNING "screen_name".id, "screen_name".screen_name;
  END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

-- GRANT EXECUTE ON FUNCTION insert_screen_name(BIGINT, VARCHAR) TO www_group;
COMMIT;

