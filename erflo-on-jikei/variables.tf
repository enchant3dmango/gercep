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

variable "iam_bindings_mode" {
  description = "The IAM bindings mode"
  type        = string
  default     = "authoritative"
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

variable "namespaces" {
  description = "The GKE namespaces to be created"
  type        = list(string)
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "regular_node_pool_locations" {
  description = "The regular node pool locations"
  type        = string
}

variable "rmsa" {
  description = "The resource manager service account (rmsa)"
  type        = string
  default     = ""
}

variable "spot_node_pool_locations" {
  description = "The spot node pool locations"
  type        = string
  default     = ""
}

variable "vpc_firewall_source_ranges" {
  description = "The VPC firewall source ranges"
  type        = list(string)
}

variable "vpc_pods_ip_cidr_range" {
  description = "The VPC pods IP CIDR range"
  type        = string
}
variable "vpc_services_ip_cidr_range" {
  description = "The VPC services IP CIDR range"
  type        = string
}

variable "zones" {
  description = "The default zones used in both node pools"
  type        = list(string)
  default     = []
}
