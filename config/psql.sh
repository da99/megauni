
psql \
  --port=311         \
  --dbname=template1 \
  --tuples-only      \
  -A                 \
  --set ON_ERROR_STOP=on \
  --set AUTOCOMMIT=off   \
  --echo-all
