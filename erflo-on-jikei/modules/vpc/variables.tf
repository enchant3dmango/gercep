variable "cluster_name" {
  description = "The name for the GKE cluster"
  type        = string
}

variable "firewall_source_ranges" {
  description = "The firewall source ranges"
  type        = list(string)
}

variable "nat_log_config_filter" {
  description = "The NAT log config filter"
  type        = string
  default     = "ERRORS_ONLY"
}

variable "nat_ip_allocate_option" {
  description = "The NAT IP allocate option"
  type        = string
  default     = "AUTO_ONLY"
}

variable "pods_ip_cidr_range" {
  description = "The pods IP CIDR range"
  type        = string
}

variable "prefix" {
  description = "The resource name prefix"
  type        = string
  default     = "gke"
}

variable "project_id" {
  description = "The project ID to host the network in"
  type        = string
}

variable "region" {
  description = "The region to host the network in"
  type        = string
}

variable "routing_mode" {
  description = "The routing mode"
  type        = string
  default     = "GLOBAL"
}

variable "services_ip_cidr_range" {
  description = "The services IP CIDR range"
  type        = string
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "The source subnet IP ranges to NAT"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
