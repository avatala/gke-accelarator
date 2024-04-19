resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = var.vpc_host_project_name
  service_project = module.create-gcp-project.project.project_id
  depends_on = [module.create-gcp-project]
}