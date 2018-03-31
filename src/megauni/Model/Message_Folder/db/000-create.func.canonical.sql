
CREATE OR REPLACE FUNCTION message_folder_canonical(
  IN raw_name VARCHAR
)
RETURNS VARCHAR
AS $$
DECLARE
  original      CONSTANT VARCHAR NOT NULL := raw_name;
  invalid_chars VARCHAR;
  pattern       CONSTANT VARCHAR  NOT NULL := '[a-zA-Z0-9\_\-\.\ \@\!\#\%\^\&\+\~]+';
  min_length    CONSTANT SMALLINT NOT NULL := 1;
  max_length    CONSTANT SMALLINT NOT NULL := 30;
BEGIN

  IF raw_name IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;

  raw_name := squeeze_whitespace(upper(raw_name));

  IF char_length(raw_name) < min_length THEN
    RAISE EXCEPTION 'invalid message folder: too short: %', min_length;
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
