
-- UP
CREATE OR REPLACE FUNCTION screen_name_insert(
  IN  owner_id BIGINT,
  IN  raw_screen_name VARCHAR,
  OUT new_screen_name VARCHAR
)
AS $$
  DECLARE
    new_screen_name_record RECORD;
    clean_screen_name VARCHAR;

  BEGIN
    clean_screen_name := screen_name_canonical(raw_screen_name);
    INSERT INTO screen_name (owner_id, screen_name)
    VALUES (owner_id, clean_screen_name)
    RETURNING "screen_name".screen_name
    INTO new_screen_name;
  END
$$ LANGUAGE plpgsql;



