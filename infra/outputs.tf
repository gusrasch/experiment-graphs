# Output the function URL
output "function_url" {
  value = google_cloudfunctions_function.callback_function.https_trigger_url
}

output "bucket_path" {
    value = google_storage_bucket.data_bucket.url
}
