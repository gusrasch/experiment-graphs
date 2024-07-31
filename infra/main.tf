# Create a GCS bucket
resource "google_storage_bucket" "data_bucket" {
  name     = var.bucket_name
  location = var.region
}

# Create a secret to store the API token
resource "google_secret_manager_secret" "groupme_gus_api_token" {
  secret_id = "groupme-gus-api-token"

  replication {
    auto {}
  }
}

# Create a service account for the Cloud Function
resource "google_service_account" "function_account" {
  account_id   = "cloud-function-sa"
  display_name = "Cloud Function Service Account"
}

# Grant the service account access to the secret
resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.groupme_gus_api_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.function_account.email}"
}

# Create the Cloud Function
resource "google_cloudfunctions_function" "callback_function" {
  name        = "callback-function"
  description = "Function to handle callback and send POST request"
  runtime     = "python310"

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.data_bucket.name
  source_archive_object = "function-source.zip"
  trigger_http          = true
  entry_point           = "handle_callback"

  environment_variables = {
    SECRET_NAME = google_secret_manager_secret.groupme_gus_api_token.name
  }

  service_account_email = google_service_account.function_account.email
}

# Define the BigQuery dataset
resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id  = "raw"
  description = "holds unprocessed data"
  location    = var.region
}

# Define the BigQuery table
resource "google_bigquery_table" "raw_messages_table" {
  dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
  table_id   = "messages"

  external_data_configuration {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris   = ["gs://${var.bucket_name}/formatted/messages.json"]
  }

  deletion_protection = false
}

# Define the BigQuery table
resource "google_bigquery_table" "raw_messages_table_pq" {
  dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
  table_id   = "members"

  external_data_configuration {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris   = ["gs://${var.bucket_name}/formatted/members.json"]
  }

  deletion_protection = false
}
