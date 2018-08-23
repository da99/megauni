
SET ROLE www_definer;

CREATE OR REPLACE FUNCTION insert_post(
  IN privacy     privacy_level,
  IN activity_id BIGINT,
  IN author_id   BIGINT
) RETURNS BIGINT AS $$
<<fn>>
DECLARE
  new_post RECORD;
BEGIN

  INSERT INTO post ( id, privacy, activity_id, author_id )
  VALUES (DEFAULT, insert_post.privacy, insert_post.activity_id, insert_post.author_id)
  RETURNING * INTO new_post;

  RETURN new_post.id;
END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

COMMIT;
