
CREATE OR REPLACE FUNCTION clean_new_screen_name(INOUT sn VARCHAR)
AS $$
  BEGIN
    sn := screen_name_canonical(sn);

    -- Banned screen names:
    IF sn ~* '(SCREEN[\_\.\-\+]+NAME|MEGAUNI|MINIUNI|OKDOKI|okjak|okjon|XXX)' OR
       sn ~* '^(BOT|ME|MINE|MY|MI|[.]+-COLA|UNDEFINED|DEF|SEX|SEXY|ALAN|TED|LARRY|ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)$'
    THEN
      RAISE EXCEPTION 'invalid screen_name: not_available';
    END IF;
  END
$$
LANGUAGE plpgsql
IMMUTABLE;




