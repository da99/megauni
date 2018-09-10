

SET ROLE base_definer;

CREATE OR REPLACE FUNCTION base.squeeze_whitespace(
  IN raw_string VARCHAR
)
RETURNS VARCHAR
AS $$
DECLARE
fin_string VARCHAR;
BEGIN
  fin_string := regexp_replace(trim(from raw_string), '\s+', ' ', 'g');
  RETURN trim(fin_string);
END
$$
LANGUAGE plpgsql
IMMUTABLE
SECURITY INVOKER
SET search_path = base , pg_temp
;

COMMIT;
