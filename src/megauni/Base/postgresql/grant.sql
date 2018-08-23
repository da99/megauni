
RESET ROLE;

REVOKE ALL PRIVILEGES ON DATABASE megauni_db FROM PUBLIC CASCADE;
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

GRANT CONNECT ON DATABASE megauni_db TO www_group ;
GRANT CREATE, USAGE ON SCHEMA base TO www_definer ;
GRANT         USAGE ON SCHEMA base TO www_group ;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON screen_name.screen_name
TO www_definer;
-- ON screen_name.screen_name, member, post, post_permit, activity_permit, conversation, "comment", comment_permit

GRANT USAGE, SELECT
ON screen_name.screen_name_id_seq
TO www_definer;
-- ON member_id_seq, screen_name_id_seq, post_id_seq, conversation_id_seq, comment_id_seq

-- RESET ROLE;
-- ALTER DEFAULT PRIVILEGES FOR ROLE www_definer REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

COMMIT;
