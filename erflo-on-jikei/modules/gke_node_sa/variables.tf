variable "cluster_name" {
  description = "The ID of the GKE cluster"
  type        = string
}

variable "gke_node_sa_roles" {
  description = "The GKE node service account roles"
  type        = list(string)
  default     = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

# Resource manager service account
variable "rm_service_account" {
  description = "The resource manager service account"
  type        = string
}
