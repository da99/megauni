
SET ROLE db_owner;

CREATE TYPE conversation_permit_type AS ENUM (
  'read',
  'read_and_reply',
  'update',
  'censor_comment'
);
COMMIT;
