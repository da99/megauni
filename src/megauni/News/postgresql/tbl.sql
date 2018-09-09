
SET ROLE db_owner;

CREATE TABLE news.tbl (
  id         BIGSERIAL    PRIMARY KEY,
  owner_id   %type.screen_name.screen_name.id,
  title      VARCHAR(255),
  body       TEXT NOT NULL,
  created_at timestamptz  NOT NULL DEFAULT NOW()
);

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
on news.tbl to news_definer;

GRANT USAGE, SELECT
ON news.tbl_id_seq TO news_definer;
COMMIT;
