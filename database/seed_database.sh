source .env
sqlcmd -S $DB_HOST,1433 -U $DB_USER -P $DB_PASSWORD -d $DB_NAME -i seed_data.sql -C