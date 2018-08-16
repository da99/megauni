
SET ROLE www_definer;

CREATE OR REPLACE FUNCTION insert_conversation(
  IN author_id BIGINT,
  IN title     VARCHAR,
  IN body      TEXT
) RETURNS BIGINT AS $$
<<fn>>
  DECLARE
    new_conversation RECORD;
  BEGIN
    INSERT INTO conversation ( id, author_id, title, body, created_at )
    VALUES (
      DEFAULT,
      insert_conversation.author_id,
      insert_conversation.title,
      insert_conversation.body,
      DEFAULT
    )
    RETURNING * INTO new_conversation;

    RETURN new_conversation.id;
  END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

COMMIT;

