variable "cluster_name" {
  description = "The ID of the GKE cluster"
  type        = string
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
