
CREATE OR REPLACE FUNCTION clean_new_label(IN raw_label VARCHAR)
RETURNS VARCHAR
AS $$
DECLARE
  valid_chars VARCHAR;
BEGIN

  IF raw_label IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;
  IF char_length(raw_label) < 1 THEN
    RAISE EXCEPTION 'invalid label: too short: 1';
  END IF;

  IF char_length(raw_label) > 30 THEN
    RAISE EXCEPTION 'invalid label: too long: 30';
  END IF;

  valid_chars := 'A-Za-z\d\-\_\^\%\$\@\*\!\~\+\=';
  IF raw_label !~ ('\A[' || valid_chars || ']+\Z') THEN
    RAISE EXCEPTION 'invalid label: invalid chars: %', regexp_replace(raw_label, ('[' || valid_chars || ']+'), '', 'ig');
  END IF;

  RETURN raw_label;

END
$$
LANGUAGE plpgsql
IMMUTABLE;
