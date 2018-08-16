
SET ROLE www_definer;

CREATE OR REPLACE FUNCTION insert_post_permit(
  IN permit_type post_permit_type,
  IN post_id     BIGINT,
  IN grantor_id  BIGINT,
  IN holder_id   BIGINT
) RETURNS BIGINT AS $$
<<fn>>
DECLARE
  new_permit      RECORD;
  post_record     POST;
  activity_permit RECORD;
BEGIN

  IF insert_post_permit.grantor_id = insert_post_permit.holder_id THEN
    RAISE EXCEPTION 'denied: you are granting a permission onto yourself';
  END IF;

  SELECT post_record.id AS id, activity.activity_type AS activity_type
  INTO post_record
  FROM post LEFT JOIN activity
  ON post.activity_id = activity.id
  WHERE post.id = insert_post_permit.post_id;

  IF post_record IS NULL THEN
    RAISE EXCEPTION 'not_found: post';
  END IF;

  IF (insert_post_permit.permit_type = 'recipient' AND post_record.activity_type = 'mail') OR
    (insert_post_permit.permit_type = 'player' AND post_record.activity_type = 'game') THEN

    SELECT id, permit_type INTO activity_permit
    FROM activity_permit
    WHERE
    activity_permit.activity_id    = post.activity_id AND
    activity_permit.grantor_id     = insert_post_permit.holder_id     AND
    activity_permit.holder_id      = insert_post_permit.grantor_id    AND
    activity_permit.screen_name_id = insert_post_permit.holder_id     AND
    activity_permit.permit_type    = 'add_me'         AND
    activity_permit.active         = TRUE;

  END IF;

  IF activity_permit IS NOT NULL THEN
    INSERT INTO post_permit (id, permit_type, post_id, grantor_id, holder_id)
    VALUES (DEFAULT, insert_post_permit.permit_type, insert_post_permit.post_id, insert_post_permit.grantor_id, insert_post_permit.holder_id)
    RETURNING * INTO new_permit;
    RETURN new_permit.id;
  END IF;

  RAISE EXCEPTION 'denied: not allowed to create post.';
END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

COMMIT;
