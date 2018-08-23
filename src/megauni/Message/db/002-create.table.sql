
CREATE TABLE IF NOT EXISTS "message" (
  id             BIGSERIAL PRIMARY KEY,
  status_id      SMALLINT  NOT NULL DEFAULT type_id('Draft'),
  owner_id       BIGINT    NOT NULL, -- refers to screen_name id

  parent_id      BIGINT    NOT NULL, -- refers to object id (news, reply, etc.)
  parent_type_id SMALLINT  NOT NULL, -- refers to used to determine object type (news, reply, etc.)

  origin_id      BIGINT    NOT NULL, -- refers to top most object, to determine privacy
  origin_type_id SMALLINT  NOT NULL,

  title          VARCHAR(140),
  body           TEXT,

  created_at     timestamptz NOT NULL DEFAULT NOW(),
  CONSTRAINT title_or_body CHECK (title IS NOT NULL OR body IS NOT NULL)
);
