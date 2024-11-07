# VPC and subnet configuration
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.3"

  project_id   = var.project_id
  network_name = "${var.prefix}-${var.cluster_name}-network"
  routing_mode = var.routing_mode

  subnets = [
    {
      subnet_name           = "${var.prefix}-${var.cluster_name}-subnet"
      subnet_ip             = "10.0.0.0/20"
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]

  secondary_ranges = {
    "${var.prefix}-${var.cluster_name}-subnet" = [
      {
        range_name    = "${var.prefix}-${var.cluster_name}-pods"
        ip_cidr_range = var.pods_ip_cidr_range
      },
      {
        range_name    = "${var.prefix}-${var.cluster_name}-services"
        ip_cidr_range = var.services_ip_cidr_range
      }
    ]
  }
}

# Cloud NAT for private GKE clusters
resource "google_compute_router" "this" {
  name    = "${var.prefix}-${var.cluster_name}-router"
  project = var.project_id
  region  = var.region
  network = module.vpc.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.prefix}-${var.cluster_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  log_config {
    enable = true
    filter = var.nat_log_config_filter
  }
}

# Firewall rules
resource "google_compute_firewall" "this" {
  name    = "${var.prefix}-${var.cluster_name}-firewall"
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

  source_ranges = var.firewall_source_ranges
}
