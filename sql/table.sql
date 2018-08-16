
\connect "megauni_db" ;
SET ROLE db_owner ;

SELECT table_name
FROM information_schema.tables
WHERE table_catalog = 'megauni_db'
AND table_schema = 'megauni_schema'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

