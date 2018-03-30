
CREATE OR REPLACE FUNCTION screen_name_canonical(INOUT sn varchar)
AS $$
  DECLARE
    valid_pattern VARCHAR := '[A-Z\d\-\_\^]+';
    invalid_chars VARCHAR;
  BEGIN
    -- screen_name
    IF sn IS NULL THEN
      RAISE EXCEPTION 'programmer_error: NULL value';
    END IF;
    sn := regexp_replace(upper(sn), '^\@|[\s[:cntrl:]]+', '', 'ig');

    IF char_length(sn) < 3 THEN
      RAISE EXCEPTION 'invalid screen_name: too short: 3';
    END IF;

    IF char_length(sn) > 30 THEN
      RAISE EXCEPTION 'invalid screen_name: too long: 30';
    END IF;

    invalid_chars := regexp_replace(sn, valid_pattern, '', 'g');
    IF bit_length(invalid_chars) > 0 THEN
      RAISE EXCEPTION 'invalid screen_name: invalid chars: %', invalid_chars;
    END IF;

  END
$$
LANGUAGE plpgsql
IMMUTABLE;




