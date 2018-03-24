

CREATE OR REPLACE FUNCTION privacy_id (
  IN raw_name VARCHAR
)
RETURNS SMALLINT
AS $$
BEGIN
  CASE raw_name
  WHEN 'ME ONLY'       THEN RETURN 0;   -- Only the owner can read it.
  WHEN 'LIST'          THEN RETURN 1;   -- Only selected people.
  WHEN 'WORLD'         THEN RETURN 100; -- Readable by world

  /*
    Specification:
    An object can be viewed by 'LIST'. This means:
      - list(s) of people. These lists/groups/circles are made before or after
        object is created.
      - specific people just for this object.
  */

  ELSE
    RAISE EXCEPTION 'programmer_error: name for privacy_id not found: %', raw_name;
  END CASE;
END
$$
LANGUAGE plpgsql
IMMUTABLE
;

