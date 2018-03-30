
CREATE OR REPLACE FUNCTION squeeze_whitespace(
  IN raw_string VARCHAR
)
RETURNS VARCHAR
AS $$
DECLARE
  fin_string VARCHAR;
BEGIN
  fin_string := regexp_replace(trim(from raw_string), '\s+', ' ', 'g');
  RETURN fin_string;
END
$$
LANGUAGE plpgsql
IMMUTABLE;
