
SET ROLE news_definer;

CREATE OR REPLACE FUNCTION news.insert(
) RETURNS TABLE(
  id             BIGINT,
) AS $$
  DECLARE
    new_news RECORD;
  BEGIN
  END
$$
LANGUAGE plpgsql
SECURITY DEFINER
;

COMMIT;
