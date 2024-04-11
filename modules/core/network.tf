# google_compute_network
resource "google_compute_network" "kojima_network_prod" {
  name                    = "kojima-network-prod"
  auto_create_subnetworks = false
}

# google_compute_subnetwork
resource "google_compute_subnetwork" "kojima_network_subnet_prod" {
  name          = "kojima-network-subnet-prod"
  ip_cidr_range = "10.1.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.kojima_network_prod.id
}

# google_compute_firewall
resource "google_compute_firewall" "kojima_network_prod_allow_ssh" {
  name        = "kojima-network-prod-allow-ssh"
  network     = google_compute_network.kojima_network_prod.name
  description = "Allow ssh from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "kojima_network_prod_allow_http" {
  name        = "kojima-network-prod-allow-http"
  network     = google_compute_network.kojima_network_prod.name
  description = "Allow http from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}

resource "google_compute_firewall" "kojima_network_prod_allow_https" {
  name        = "kojima-network-prod-allow-https"
  network     = google_compute_network.kojima_network_prod.name
  description = "Allow https from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-https"]
}

resource "google_compute_firewall" "kojima_network_prod_allow_postgres" {
  name        = "kojima-network-prod-allow-postgres"
  network     = google_compute_network.kojima_network_prod.name
  description = "Allow Postgres Access from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-postgres"]
}

# google_compute_address
resource "google_compute_address" "kojima_network_subnet_prod" {
  name   = "kojima-network-subnet-prod"
  region = "us-central1"
}
