
SET ROLE db_owner;

-- create a post in someone else's activity.
-- create a comment
-- allow to edit a post
-- allow to edit comments
-- allow to add a person (eg "Allow this person to send mail to me.")
-- Let's people create posts and comments, but most likely
--   won't allow people create other activityes, because that requires
--   usability skills which most businesses and people will never have.
CREATE TABLE "activity_permit" (
  id                   BIGSERIAL PRIMARY KEY,
  active               BOOLEAN DEFAULT true,
  activity_id          activity_name NOT NULL,
  grantor_id           BIGINT NOT NULL, -- screen_name id of permit grantor/author
  holder_id            BIGINT NOT NULL, -- screen_name id of permit holder
  created_at           timestamptz NOT NULL DEFAULT NOW()
);

COMMIT;
