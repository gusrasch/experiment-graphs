# Define input variables
variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "bucket_name" {
  description = "The name of the Google Cloud Storage bucket"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "us-central1"
}

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a GCS bucket
resource "google_storage_bucket" "data_bucket" {
  name     = var.bucket_name
  location = "US"
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
  secret_id = google_secret_manager_secret.api_token.id
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
    SECRET_NAME = google_secret_manager_secret.api_token.name
  }

  service_account_email = google_service_account.function_account.email
}

# Output the function URL
output "function_url" {
  value = google_cloudfunctions_function.callback_function.https_trigger_url
}
