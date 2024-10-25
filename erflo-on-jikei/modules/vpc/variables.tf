variable "cluster_name" {
  description = "The name for the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "The project ID to host the network in"
  type        = string
}

variable "region" {
  description = "The region to host the network in"
  type        = string
}
