
SET ROLE db_owner;

-- 'high_priority': No type like this. It is subjective and left to recipeitn
--   to determine which posts are high priority.
CREATE TYPE activity_type AS ENUM (
  'mail',
  'game',
  'advertisement',
  'flirt'
  'sale_events',
  'events'
);

COMMIT;

