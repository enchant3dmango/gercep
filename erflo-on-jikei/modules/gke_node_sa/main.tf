# Create random suffix for the service account
resource "random_id" "cluster_suffix" {
  byte_length = 4
}

# Create GKE Node Service Account
resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-${var.cluster_name}-${random_id.cluster_suffix.hex}"
  display_name = "GKE node service account for ${var.cluster_name}"
  project      = var.project_id
}

# Assign required roles to the service account for project-level permissions
resource "google_project_iam_member" "gke_node_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

# Grant the service account permissions on itself
resource "google_service_account_iam_binding" "gke_node_sa_user" {
  service_account_id = google_service_account.gke_node_sa.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.rm_service_account}",
  ]
}
