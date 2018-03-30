
CREATE OR REPLACE FUNCTION message_type_canonical(
  IN raw_name VARCHAR
)
RETURNS VARCHAR
AS $$
DECLARE
  semi_clean    VARCHAR;
  invalid_chars VARCHAR;
  pattern       VARCHAR  := '[A-Z0-9\_\-\.\ \@\!\#\%\^\&\+\~]+';
  max_length    SMALLINT := 30;
BEGIN

  semi_clean := squeeze_whitespace(upper(raw_name));

  IF char_length(semi_clean) > max_length THEN
    RAISE EXCEPTION 'invalid message type: too long: %', max_length;
  END IF;

  invalid_chars := regexp_replace(semi_clean, pattern, '', 'ig');
  IF bit_length(invalid_chars) > 0 THEN
    RAISE EXCEPTION 'invalid message type: invalid chars: %', invalid_chars;
  END IF;

  RETURN semi_clean;
END
$$
LANGUAGE plpgsql;
