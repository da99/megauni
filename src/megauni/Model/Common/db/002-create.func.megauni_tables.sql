
CREATE OR REPLACE VIEW megauni_tables
AS
SELECT table_name
FROM information_schema.tables
WHERE table_catalog = 'megauni_db'
AND table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;

COMMIT;
