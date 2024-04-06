output "google_compute_subnetwork" {
  value = {
    "kojima_network_subnet_prod" :  google_compute_subnetwork.kojima_network_subnet_prod,
  }
}

output "google_compute_address" {
  value = {
    "kojima_network_subnet_prod" : google_compute_address.kojima_network_subnet_prod
  }
}
