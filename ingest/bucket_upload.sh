duckdb -c $(cat readjson.sql)
# duckdb -c ();
# gsutil -m cp -r ./data/* gs://groupme-bot-bucket/raw/messages/
# gsutil -m cp -r ./ingest/data/formatted/8860110_history.parquet gs://groupme-bot-bucket/formatted/messages/8860110_history.parquet
# gsutil -m cp -r ./ingest/data/formatted/messages.json gs://groupme-bot-bucket/formatted/messages/8860110_history.json
# gsutil -m cp -r ./ingest/data/formatted/* gs://groupme-bot-bucket/formatted/
gsutil -m --help