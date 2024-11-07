# Create service account
resource "google_service_account" "this" {
  account_id   = "${var.prefix}-${var.name}"
  display_name = "The ${var.name} GCP service account"
  project      = var.project_id
}

# Assign required roles to the service account for project-level permissions
resource "google_project_iam_member" "this" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}

# Grant the service account permissions to resource manager service account
resource "google_service_account_iam_binding" "this" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.rmsa}",
  ]
}
