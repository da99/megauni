
CREATE OR REPLACE FUNCTION member_insert(
  IN  sn_name   varchar,
  IN  pswd_hash varchar
) RETURNS TABLE(
  id             screen_name.owner_id%TYPE,
  screen_name_id screen_name.id%TYPE,
  screen_name    screen_name.screen_name%TYPE
) AS $$
  DECLARE
    new_member RECORD;
  BEGIN
    IF pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF length(pswd_hash) < 60 THEN
      RAISE EXCEPTION 'programmer_error: invalid pswd_hash';
    END IF;

    INSERT INTO
    "member" ( id, pswd_hash )
    VALUES ( DEFAULT, pswd_hash::BYTEA )
    RETURNING * INTO new_member;

    RETURN QUERY
    SELECT
    new_member.id    AS id,
    sn_i.id          AS screen_name_id,
    sn_i.screen_name AS screen_name
    FROM screen_name_insert(new_member.id, sn_name) AS sn_i;
  END
$$ LANGUAGE plpgsql;

COMMIT;
