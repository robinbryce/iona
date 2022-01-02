
resource "google_compute_network" "gke-network" {
  name                    = var.cluster_name
  project                 = var.project
  auto_create_subnetworks = false
}

output "vpc_network" { value = google_compute_network.gke-network.id }

# private service connections are the recomended way for enabling access to
# memorystore (aka managed redis)
# https://cloud.google.com/memorystore/docs/redis/creating-managing-instances#creating_a_redis_instance_with_a_shared_vpc_network_in_a_service_project
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  project       = var.project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.gke-network.id
}

resource "google_service_networking_connection" "googleapis" {
  network                 = google_compute_network.gke-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "gke-subnet" {
  name          = var.cluster_name
  region        = var.region
  project       = var.project
  network       = google_compute_network.gke-network.id
  ip_cidr_range = var.subnet_cidr_range

  secondary_ip_range {
    range_name    = var.cluster_range_name
    ip_cidr_range = var.cluster_range_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_range_cidr
  }

  # VMs without external IP can access Google APIs through Private Google Access
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_router" "gke-router" {
  name    = var.cluster_name
  region  = var.region
  project = var.project
  network = google_compute_network.gke-network.id
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "gke-nat" {
  name                               = var.cluster_name
  project                            = var.project
  router                             = google_compute_router.gke-router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  subnetwork {
    name                    = google_compute_subnetwork.gke-subnet.self_link
    source_ip_ranges_to_nat = var.source_ip_ranges_to_nat
  }
  log_config {
    filter = var.nat_log_filter
    enable = true
  }

  # Hard code these values, because every other terraform apply wants to either set them to null, or to these values
  icmp_idle_timeout_sec            = 30
  tcp_established_idle_timeout_sec = 1200
  tcp_transitory_idle_timeout_sec  = 30
  udp_idle_timeout_sec             = 30
}

resource "google_compute_address" "static-ingress" {
  name     = "static-ingress"
  project  = var.project
  region   = var.region
  provider = google-beta

  # address labels are a beta feature
  labels = {
    kubeip = "static-ingress"
  }
}

# By default, firewall rules restrict cluster master to only initiate TCP connections to nodes on ports 443 (HTTPS) and 10250 (kubelet)
resource "google_compute_firewall" "default" {
  name    = "web-ingress"
  network = google_compute_network.gke-network.self_link
  project = var.project

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.node_pools_tags.ingress-pool
}
