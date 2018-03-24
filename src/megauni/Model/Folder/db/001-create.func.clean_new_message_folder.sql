
CREATE OR REPLACE FUNCTION clean_new_message_folder (
  INOUT raw_name VARCHAR
)
AS $$
DECLARE
valid_chars VARCHAR;
BEGIN
  IF raw_name IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;
  IF char_length(raw_name) < 1 THEN
    RAISE EXCEPTION 'invalid message folder: too short: 1';
  END IF;

  IF char_length(raw_name) > 30 THEN
    RAISE EXCEPTION 'invalid message folder: too long: 30';
  END IF;

  valid_chars := 'A-Za-z\d\-\_\^\%\$\@\*\!\~\+\=';
  IF raw_name !~ ('\A[' || valid_chars || ']+\Z') THEN
    RAISE EXCEPTION 'invalid message folder: invalid chars: %', regexp_replace(raw_name, ('[' || valid_chars || ']+'), '', 'ig');
  END IF;
END
$$
LANGUAGE plpgsql
IMMUTABLE ;
