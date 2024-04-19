data "google_compute_network" "shared_vpc" {
  name    = var.network_name
  project = var.vpc_host_project_name
}