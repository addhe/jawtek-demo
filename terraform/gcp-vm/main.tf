# ============================================================
# GCP Compute Engine VM — Agnostic DevOps Template
# ============================================================

# --- Data Sources ---
data "google_client_config" "default" {}

# --- Local Values ---
locals {
  machine_type = var.environment == "production" ? var.machine_type_prod : var.machine_type_dev

  common_labels = merge({
    environment  = var.environment
    managed-by   = "terraform"
    project      = var.project_id
  }, var.tags)

  subnet_name = "${var.vpc_name}-${var.environment}-subnet"
}

# ============================================================
# VPC & Networking
# ============================================================

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = local.subnet_name
  network       = google_compute_network.vpc.id
  region        = var.region
  ip_cidr_range = var.subnet_cidr
  project       = var.project_id
}

# --- Cloud NAT (for outbound internet without public IP on VMs) ---
resource "google_compute_router" "router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id
}

# ============================================================
# Firewall Rules
# ============================================================

# SSH via IAP only
resource "google_compute_firewall" "ssh_iap" {
  name      = "${var.vpc_name}-allow-ssh-iap"
  network   = google_compute_network.vpc.id
  project   = var.project_id
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = ["${var.vm_name}-${var.environment}"]
}

# HTTP/HTTPS inbound
resource "google_compute_firewall" "http_https" {
  name      = "${var.vpc_name}-allow-http-https"
  network   = google_compute_network.vpc.id
  project   = var.project_id
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.allowed_http_cidrs
  target_tags   = ["${var.vm_name}-${var.environment}"]
}

# All outbound allowed
resource "google_compute_firewall" "allow_egress" {
  name      = "${var.vpc_name}-allow-egress"
  network   = google_compute_network.vpc.id
  project   = var.project_id
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["${var.vm_name}-${var.environment}"]
}

# Internal communication between VMs
resource "google_compute_firewall" "internal" {
  name      = "${var.vpc_name}-allow-internal"
  network   = google_compute_network.vpc.id
  project   = var.project_id
  direction = "INGRESS"

  allow {
    protocol = "all"
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = ["${var.vm_name}-${var.environment}"]
}

# ============================================================
# OS Login (IAM)
# ============================================================

resource "google_compute_project_metadata_item" "os_login" {
  project = var.project_id
  key     = "enable-oslogin"
  value   = "TRUE"
}

# ============================================================
# Ops Agent Config (read from file, passed as metadata)
# ============================================================

data "local_file" "ops_agent_config" {
  filename = "${path.module}/${var.ops_agent_config_path}"
}

# ============================================================
# VM Instance
# ============================================================

resource "google_compute_instance" "vm" {
  name         = "${var.vm_name}-${var.environment}"
  machine_type = local.machine_type
  zone         = var.zone
  project      = var.project_id
  labels       = local.common_labels
  tags         = ["${var.vm_name}-${var.environment}"]

  # --- Boot Disk ---
  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  # --- Network Interface ---
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    # No external IP — use Cloud NAT for outbound, IAP for SSH
  }

  # --- OS Login Metadata ---
  metadata = {
    enable-oslogin     = "TRUE"
    startup-script     = file("${path.module}/startup-script.sh")
    ops-agent-config   = data.local_file.ops_agent_config.content
  }

  # --- Service Account ---
  service_account {
    email  = "${var.project_id}-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  # --- Allow stopping for update ---
  allow_stopping_for_update = true
}
