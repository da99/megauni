

SET ROLE db_owner;

-- RUN: --------------
CREATE TYPE object_type AS ENUM (
  'member', 'screen_name', 'follow', 'contact', 'message'
);
COMMIT;
