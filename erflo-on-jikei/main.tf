# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

module "gke_node_sa" {
  source = "./modules/gke_node_sa"

  cluster_name = var.cluster_name
  project_id   = var.project_id
}

module "gke_vpc" {
  source = "./modules/vpc"

  cluster_name = var.cluster_name
  project_id   = var.project_id
  region       = var.region
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
  service_account            = module.gke_node_sa.service_account_email

  create_service_account   = false
  remove_default_node_pool = true

  node_pools = [
    {
      name               = "regular-node-pool"
      machine_type       = var.machine_type
      min_count          = 1
      max_count          = 2
      spot               = false
      disk_size_gb       = 10
      auto_upgrade       = true
      initial_node_count = 2
      strategy           = "BLUE_GREEN"
    },
    {
      name               = "spot-node-pool"
      machine_type       = var.machine_type
      min_count          = 2
      max_count          = 4
      spot               = true
      disk_size_gb       = 10
      auto_upgrade       = true
      initial_node_count = 4
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
  source = "./modules/namespaces"
}

module "gke_namespace_secrets" {
  source = "./modules/secrets"
}
