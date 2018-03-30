
CREATE OR REPLACE FUNCTION message_folder_canonical(
  IN raw_name VARCHAR
)
RETURNS VARCHAR
AS $$
DECLARE
  original      VARCHAR;
  invalid_chars VARCHAR;
  pattern       VARCHAR  := '[a-zA-Z0-9\_\-\.\ \@\!\#\%\^\&\+\~]+';
  max_length    SMALLINT := 30;
BEGIN

  original := raw_name;

  IF raw_name IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;

  raw_name := squeeze_whitespace(upper(raw_name));

  IF char_length(raw_name) < 1 THEN
    RAISE EXCEPTION 'invalid message folder: too short: 1';
  END IF;

  IF char_length(raw_name) > max_length THEN
    RAISE EXCEPTION 'invalid message folder: too long: %', max_length;
  END IF;

  invalid_chars := regexp_replace(raw_name, pattern, '', 'g');
  IF bit_length(invalid_chars) > 0 THEN
    RAISE EXCEPTION 'invalid message folder: invalid chars: %', invalid_chars;
  END IF;

  RETURN raw_name;
END
$$
LANGUAGE plpgsql
IMMUTABLE;
