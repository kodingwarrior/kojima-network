variable "public_key_for_kojima_feed" {}
variable "private_key_for_kojima_feed" {}
variable "subnetwork" {}
variable "nat_ip" {}

resource "google_compute_instance" "kojima_feed_main_prod" {
  name         = "kojima-feed-main-prod"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  network_interface {
    subnetwork = var.subnetwork.id
    access_config {
      nat_ip = var.nat_ip.address
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
    ssh-keys = "kojima-feed:${var.public_key_for_kojima_feed}"
  }

  provisioner "remote-exec" {
    connection {
	  type = "ssh"
	  user = "kojima-feed"
	  host = var.nat_ip.address
	  private_key = var.private_key_for_kojima_feed
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
      "sudo usermod -a -G sudo,docker kojima-feed",
      "sudo docker network create -d bridge private",

      "sudo chmod 600 /home/kojima-feed/.ssh/*",
    ]
  } 
}
