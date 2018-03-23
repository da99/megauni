
CREATE OR REPLACE FUNCTION user_insert(
  IN  sn_name     varchar,
  IN  pswd_hash   varchar,
  OUT new_user_id bigint,
  OUT new_screen_name text
)
AS $$
  DECLARE
    temp_rec RECORD;
  BEGIN
    IF pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF length(pswd_hash) < 10 THEN
      RAISE EXCEPTION 'programmer_error: invalid pswd_hash';
    END IF;

    INSERT INTO
    "user" ( id, pswd_hash )
    VALUES ( DEFAULT, pswd_hash::BYTEA )
    RETURNING id INTO temp_rec;

    new_user_id := temp_rec.id;

    SELECT *
    INTO temp_rec
    FROM screen_name_insert(new_user_id, sn_name);

    new_screen_name := temp_rec.new_screen_name;
  END
$$ LANGUAGE plpgsql;


