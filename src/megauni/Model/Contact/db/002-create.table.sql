
CREATE TABLE IF NOT EXISTS "contact" (
  id BIGSERIAL PRIMARY KEY,
  owner_id BIGINT NOT NULL, -- refers to screen_name id
  contact_id BIGINT NOT NULL -- refers to screen_name id
);
