variable "kojima_network" {}
variable "public_key_for_kojima_memedex" {}
variable "private_key_for_kojima_memedex" {}

# google_compute_subnetwork
resource "google_compute_subnetwork" "kojima_memedex_subnet_prod" {
  name 			= "kojima-memedex-subnet-prod"
  ip_cidr_range = "10.2.0.0/16"
  region 		= "us-central1"
  network 		= var.kojima_network.id
}

# google_compute_address
resource "google_compute_address" "kojima_memedex_ip_address" {
  name   = "kojima-memedex-ip-address"
  region = "us-central1"
}

resource "google_compute_instance" "kojima_memedex_main_prod" {
  name         = "kojima-memedex-main-prod"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  network_interface {
    subnetwork = google_compute_subnetwork.kojima_memedex_subnet_prod.id
    access_config {
      nat_ip = google_compute_address.kojima_memedex_ip_address.address
    }
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20240319"
	  size = 25
    }
  }

  tags = ["allow-http", "allow-ssh", "allow-postgres", "allow-https"]

  metadata = {
    ssh-keys = "kojima-memedex:${var.public_key_for_kojima_memedex}"
  }

  provisioner "remote-exec" {
    connection {
	  type = "ssh"
	  user = "kojima-memedex"
	  host = google_compute_address.kojima_memedex_ip_address.address
	  private_key = var.private_key_for_kojima_memedex
	}
    inline = [
      # releasing lock
      "sudo rm /var/lib/apt/lists/lock",

      # Adding Docker's official GPG Key
      "sudo apt-get update",
      "sudo apt-get -y install ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      # Add repository to Apt source
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      # Build docker private network
      "sudo usermod -a -G sudo,docker kojima-memedex",
      "sudo docker network create -d bridge private",

      "sudo chmod 600 /home/kojima-memedex/.ssh/*",
    ]
  } 
}
