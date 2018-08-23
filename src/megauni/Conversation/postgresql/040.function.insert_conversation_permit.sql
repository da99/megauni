
SET ROLE www_definer;
CREATE OR REPLACE FUNCTION insert_conversation_permit(
  IN permit_type     conversation_permit_type,
  IN conversation_id BIGINT,
  IN grantor_id      BIGINT,
  IN holder_id       BIGINT
) RETURNS BIGINT AS $$
<<fn>>
DECLARE
  allowed_to_send RECORD;
  new_permit RECORD;
BEGIN
  SELECT id INTO allowed_to_send
  FROM activity_permit
  WHERE activity_permit.active = TRUE AND
  activity_permit.grantor_id = insert_conversation_permit.holder_id AND
  activity_permit.holder_id  = insert_conversation_permit.grantor_id;

  IF allowed_to_send IS NULL OR FOUND IS NULL THEN
    RAISE EXCEPTION 'denied: not allowed to send conversation';
  END IF;

  INSERT INTO
  conversation_permit ( id, permit_type, grantor_id, holder_id )
  VALUES ( DEFAULT, 'read_and_reply', insert_conversation_permit.grantor_id, insert_conversation_permit.holder_id )
  RETURNING id INTO new_permit;

  RETURN new_permit.id;

END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

COMMIT;

