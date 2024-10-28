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

variable "rm_service_account" {
  description = "The service account used to manage resources"
  type        = string
}

variable "zones" {
  description = "The zones used in both node pools"
  type        = list(string)
  default     = []
}
