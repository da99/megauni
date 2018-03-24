

CREATE OR REPLACE FUNCTION type_id (
  IN raw_name VARCHAR
)
RETURNS SMALLINT
AS $$
BEGIN
  CASE raw_name
  WHEN 'Member'      THEN RETURN 1;
  WHEN 'Screen_Name' THEN RETURN 2;
  WHEN 'Follow'      THEN RETURN 3;

  WHEN 'Page'        THEN RETURN 10;

  ELSE
    RAISE EXCEPTION 'programmer_error: name for type_id not found: %', raw_name;
  END CASE;
END
$$
LANGUAGE plpgsql
IMMUTABLE ;

