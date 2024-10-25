variable "cluster_name" {
  description = "The name for the GKE cluster"
  type        = string
}

variable "credentials_file" {
  description = "The credentials file path"
  type        = string
}

variable "environment" {
  description = "The environment name, e.g. prod, staging, dev"
  type        = string
}

variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "machine_type" {
  description = "The default machine type"
  type        = string
  default     = "custom-8-16384"
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "service_account" {
  description = "The service account used in both node pools"
  type        = string
}

variable "zones" {
  description = "The zones used in both node pools"
  type        = list(string)
  default     = []
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 5

  validation {
    condition     = var.node_count > 0 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}
