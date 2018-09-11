
-- RESET ROLE;

REVOKE ALL PRIVILEGES ON DATABASE megauni_db FROM PUBLIC CASCADE;
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

GRANT CONNECT ON DATABASE megauni_db TO www_group ;
GRANT         USAGE ON SCHEMA base TO www_group ;
GRANT         USAGE ON SCHEMA base TO definer_group ;

-- ON screen_name.screen_name, member, post, post_permit, activity_permit, conversation, "comment", comment_permit

-- ON member_id_seq, screen_name_id_seq, post_id_seq, conversation_id_seq, comment_id_seq

-- RESET ROLE;
-- ALTER DEFAULT PRIVILEGES FOR ROLE www_definer REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

COMMIT;
