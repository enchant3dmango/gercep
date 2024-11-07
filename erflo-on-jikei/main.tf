# The google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

locals {
  service_accounts = {
    "luislang" = {
      name       = "${var.cluster_name}-luislang"
      project_id = var.project_id
      rmsa       = var.rmsa
    }
    "gke_node" = {
      name       = "${var.cluster_name}-node"
      project_id = var.project_id
      rmsa       = var.rmsa
      roles = [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer"
      ]
    }
    "airflow" = {
      name       = "${var.cluster_name}-airflow"
      project_id = var.project_id
      rmsa       = var.rmsa
      roles = [
        "roles/container.developer",
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer",
        "roles/storage.objectUser"
      ]
    }
  }
  secrets = {
    "luislang" = {
      namespace = "luislang"
      name      = "luislang-gcp-key"
      service_account = {
        name = "luislang-gcp-key"
      }
    }
    "airflow" = {
      namespace = "airflow"
      name      = "airflow-gcp-key"
      service_account = {
        name = "airflow-gcp-key"
      }
    }
  }
}

module "service_accounts" {
  for_each = local.service_accounts

  source = "./modules/service_account"

  name       = each.value.name
  project_id = each.value.project_id
  rmsa       = each.value.rmsa
  roles      = lookup(each.value, "roles", []) # Pass [] (empty list) if the roles is not defined in locals
}

module "gke_vpc" {
  source = "./modules/vpc"

  cluster_name           = var.cluster_name
  project_id             = var.project_id
  region                 = var.region
  pods_ip_cidr_range     = var.vpc_pods_ip_cidr_range
  services_ip_cidr_range = var.vpc_services_ip_cidr_range
  firewall_source_ranges = var.vpc_firewall_source_ranges
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "33.1.0"
  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.region
  zones                      = var.zones
  network                    = module.gke_vpc.network_name
  subnetwork                 = module.gke_vpc.subnet_names[0]
  ip_range_pods              = module.gke_vpc.ip_range_pods
  ip_range_services          = module.gke_vpc.ip_range_services
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false
  service_account            = module.service_accounts["gke_node"].google_service_account_email

  create_service_account   = false
  remove_default_node_pool = true
  deletion_protection      = false

  node_pools = [
    {
      name               = "regular-node-pool"
      machine_type       = var.machine_type
      node_locations     = var.regular_node_pool_locations
      min_count          = 1
      max_count          = 1
      spot               = false
      disk_size_gb       = 10
      auto_upgrade       = true
      initial_node_count = 1
      strategy           = "BLUE_GREEN"
    },
    {
      name               = "spot-node-pool"
      machine_type       = var.machine_type
      node_locations     = var.spot_node_pool_locations
      min_count          = 1
      max_count          = 2
      spot               = true
      disk_size_gb       = 10
      auto_upgrade       = true
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    regular-node-pool = {
      regular-node-pool = true
    }

    spot-node-pool = {
      spot-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    regular-node-pool = {
      node-pool-metadata-custom-value = "my-regular-node-pool"
    }

    spot-node-pool = {
      node-pool-metadata-custom-value = "my-spot-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    regular-node-pool = [
      {
        key    = "regular-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]

    spot-node-pool = [
      {
        key    = "spot-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    regular-node-pool = [
      "regular-node-pool",
    ]

    spot-node-pool = [
      "spot-node-pool",
    ]
  }
}

module "gke_namespaces" {
  source = "./modules/namespace"

  namespaces = var.namespaces
}

# Bind Luislang's related storage object user role to the Luislang service account itself
module "storage_bucket-iam-bindings" {
  source  = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "~> 8.0"

  storage_buckets = ["source", "staging", "target"]
  mode            = var.iam_bindings_mode
  bindings = {
    "roles/storage.objectUser" = [
      "serviceAccount:${module.service_accounts["luislang"].google_service_account_email}"
    ]
  }
}

# Bind Luislang service account user role to resource manager service account
module "service_account-iam-bindings" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "~> 8.0"

  service_accounts = [module.service_accounts["luislang"].google_service_account_email]
  project          = var.project_id
  mode             = var.iam_bindings_mode
  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${var.rmsa}"
    ]
  }
}

resource "google_service_account_key" "this" {
  for_each           = local.secrets
  service_account_id = module.service_accounts[each.key].google_service_account_email
}

resource "kubernetes_secret_v1" "this" {
  for_each = local.secrets

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = each.value.service_account.name
    }
  }

  data = {
    gcp_key = base64decode(google_service_account_key.this[each.key].private_key)
  }

  type = "Opaque"
}

resource "helm_release" "airflow" {
  name       = "airflow"
  namespace  = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = "1.15.0"

  values  = [file("helm/airflow/values.yaml")]
  timeout = 1200
  wait    = false
}
