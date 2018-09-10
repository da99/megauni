

SET ROLE base_definer;

CREATE TYPE base.object_type AS ENUM (
  'member', 'screen_name', 'follow', 'contact', 'message'
);

COMMIT;
