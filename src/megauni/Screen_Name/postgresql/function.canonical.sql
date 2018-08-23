
SET ROLE www_definer;

CREATE OR REPLACE FUNCTION screen_name.canonical(IN raw_name VARCHAR)
RETURNS VARCHAR
AS $$
  DECLARE
    sn VARCHAR;
    valid_pattern CONSTANT VARCHAR NOT NULL:= '[A-Z\d\-\_\^]+';
    invalid_chars VARCHAR;
    min_length    CONSTANT SMALLINT NOT NULL := 3;
    max_length    CONSTANT SMALLINT NOT NULL := 30;
  BEGIN

    IF raw_name IS NULL THEN
      RAISE EXCEPTION 'programmer_error: NULL value';
    END IF;

    sn := regexp_replace(upper(raw_name), '^\@|[\s[:cntrl:]]+', '', 'ig');

    IF char_length(sn) < min_length THEN
      RAISE EXCEPTION 'invalid screen_name: too short: %', min_length;
    END IF;

    IF char_length(sn) > max_length THEN
      RAISE EXCEPTION 'invalid screen_name: too long: %', max_length;
    END IF;

    invalid_chars := regexp_replace(sn, valid_pattern, '', 'g');
    IF bit_length(invalid_chars) > 0 THEN
      RAISE EXCEPTION 'invalid screen_name: invalid chars: %', invalid_chars;
    END IF;

    RETURN sn;

  END
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMIT;


