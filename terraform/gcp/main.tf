############################
# Enable required APIs
############################
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iap" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

############################
# VPC + Subnet (Private)
############################
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = var.subnet_name
  region        = var.region
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc.id

  private_ip_google_access = true
}

############################
# Cloud NAT for private egress
############################
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

############################
# Firewall: allow SSH via IAP only
# IAP TCP forwarding range: 35.235.240.0/20
############################
resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "${var.network_name}-allow-ssh-iap"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

############################
# VM: Ubuntu, private-only (no external IP)
# OS Login enabled (recommended)
############################
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  zone         = var.zone
  machine_type = var.machine_type
  labels       = var.labels

  tags = ["iap-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    # No access_config block => no external/public IP
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  depends_on = [
    google_compute_router_nat.nat
  ]
}
