
SET ROLE db_owner;

CREATE TYPE comment_permit_type AS ENUM (
  'read',
  'edit',
  'reply',
  'censor'
);
COMMIT;
