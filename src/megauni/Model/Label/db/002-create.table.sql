
CREATE TABLE IF NOT EXISTS "label" (
  id   BIGSERIAL   PRIMARY KEY,
  name VARCHAR(30) NOT NULL
  UNIQUE CHECK(name = clean_new_label(name))
);
