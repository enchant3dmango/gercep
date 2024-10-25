terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "17.5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"
    }
  }
  required_version = "~> 1.9"
}
