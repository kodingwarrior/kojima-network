terraform {
  required_version = ">= 0.11.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
  }

  backend "gcs" {
    bucket = "kojima-meta-network"
  }
}

provider "google" {
  credentials = "${file("/home/kodingwarrior/works/kojima-network/credentials.json")}"
  project     = "kojima-network"
  region      = "us-central1"
}

resource "tls_private_key" "ssh_key_for_kojima_network" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_for_kojima_network" {
  content         = tls_private_key.ssh_key_for_kojima_network.private_key_pem
  filename        = "kojima_network.pem"
  file_permission = "0600"
}

resource "local_file" "public_key_for_kojima_network" {
  content         = chomp(tls_private_key.ssh_key_for_kojima_network.public_key_openssh)
  filename        = "kojima_network.pub"
  file_permission = "0600"
}

module "core" {
  source = "./modules/core"
}

module "kojima_feed" {
  source = "./modules/kojima-feed"

  public_key_for_kojima_feed = local_file.public_key_for_kojima_network.content
  private_key_for_kojima_feed = local_file.private_key_for_kojima_network.content

  subnetwork       = module.core.google_compute_subnetwork["kojima_network_subnet_prod"]
  nat_ip           = module.core.google_compute_address["kojima_network_subnet_prod"]
}
