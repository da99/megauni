
SET ROLE db_owner;

CREATE TABLE "comment" (
  id         BIGSERIAL PRIMARY KEY,

  -- Comments can be:
  --   'me_only' -- readable only by comment author
  --   'private' -- (between post authors and me)
  --   'public' -- readable by the same people as post.
  privacy    privacy_level NOT NULL DEFAULT 'private',

  post_id    BIGINT        NOT NULL,
  author_id  BIGINT        NOT NULL, -- screen_name id
  body       text          NOT NULL,
  created_at timestamptz   NOT NULL DEFAULT NOW()
);

COMMIT;
