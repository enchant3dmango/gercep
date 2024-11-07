variable "name" {
  description = "The service acccount name"
  type        = string
}

variable "prefix" {
  description = "The service acccount name prefix"
  type        = string
  default     = "gke"
}

variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "rmsa" {
  description = "The resource manager service account (rmsa)"
  type        = string
}

variable "roles" {
  description = "The service account roles"
  type        = list(string)
  default     = []
}
