# Output the service account email for reference
output "service_account_email" {
  description = "The email address of the GKE node service account"
  value       = google_service_account.gke_node_sa.email
}
