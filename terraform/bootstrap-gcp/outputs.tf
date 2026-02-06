output "state_bucket_name" {
  description = "GCS bucket name for Terraform remote state"
  value       = google_storage_bucket.tf_state.name
}

output "project_id" {
  description = "GCP project id"
  value       = var.project_id
}

output "location" {
  description = "GCS bucket location"
  value       = var.location
}
