
CREATE OR REPLACE VIEW readable_screen_name
AS
SELECT screen_name.*
FROM screen_name JOIN "member"
ON screen_name.owner_id = "member".id;
