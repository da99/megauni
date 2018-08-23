
SET ROLE db_owner;

CREATE TYPE post_permit_type AS ENUM (
  'read',
  'create_comment',
  'censor',
  'player',
  'recipient'
);
COMMIT;
