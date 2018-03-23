
CREATE OR REPLACE FUNCTION screen_name_canonical(inout sn varchar)
AS $$
  DECLARE
    valid_chars VARCHAR;
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

    valid_chars := 'A-Z\d\-\_\^';
    IF sn !~ ('\A[' || valid_chars || ']+\Z') THEN
      RAISE EXCEPTION 'invalid screen_name: invalid chars: %', regexp_replace(sn, ('[' || valid_chars || ']+'), '', 'ig');
    END IF;

  END
$$
LANGUAGE plpgsql
IMMUTABLE
;




