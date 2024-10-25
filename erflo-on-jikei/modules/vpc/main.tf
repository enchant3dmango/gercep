# VPC and subnet configuration
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.3"

  project_id   = var.project_id
  network_name = "gke-${var.cluster_name}-network"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "gke-${var.cluster_name}-subnet"
      subnet_ip             = "10.0.0.0/20"
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]

  secondary_ranges = {
    "gke-${var.cluster_name}-subnet" = [
      {
        range_name    = "gke-${var.cluster_name}-pods"
        ip_cidr_range = "10.16.0.0/16"
      },
      {
        range_name    = "gke-${var.cluster_name}-services"
        ip_cidr_range = "10.17.0.0/16"
      }
    ]
  }
}

# Cloud NAT for private GKE clusters
resource "google_compute_router" "router" {
  name    = "gke-${var.cluster_name}-router"
  project = var.project_id
  region  = var.region
  network = module.vpc.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "gke-${var.cluster_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "gke-${var.cluster_name}-firewall"
  network = module.vpc.network_name
  project = var.project_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    "10.0.0.0/20",
    "10.1.0.0/20",
    "10.16.0.0/16",
    "10.17.0.0/16"
  ]
}
