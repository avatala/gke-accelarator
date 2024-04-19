## Adding kubernetes service-[PROJECT_ID]@container-engine-robot.iam.gserviceaccount.com service account to shared project

locals {
    service_agent_email = "service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
    google_compute_engine_email = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    project_serivce_account = "${data.google_project.project.number}@cloudservices.gserviceaccount.com"
    host_google_compute_engine_email = "${data.google_project.host_project.number}-compute@developer.gserviceaccount.com"
    multi_tenant_cloud_build_account = "${data.google_project.multi_tenant_project.number}@cloudbuild.gserviceaccount.com"
    multi_tenant_service_agent_email = "service-${data.google_project.multi_tenant_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

data "google_project" "project" {
    project_id = module.create-gcp-project.project.project_id
    depends_on = [module.create-gcp-project]
}


data "google_project" "host_project" {
    project_id = var.vpc_host_project_name
}



data "google_project" "multi_tenant_project" {
    project_id = var.project_id
}

#### TO BE DELETED 

resource "google_project_iam_binding" "gke-project-owner" {
  project = data.google_project.project.project_id 
  role    = "roles/owner"

  members = [
     "serviceAccount:${local.multi_tenant_cloud_build_account}",
  ]
  depends_on = [
    google_project_iam_binding.compute-security-admin,
  ]
}


###### 

resource "google_project_iam_binding" "compute-networkuser" {
  project = var.vpc_host_project_name
  role    = "roles/compute.networkUser"

  members = [
     "serviceAccount:${local.google_compute_engine_email}",  
     #"serviceAccount:${local.host_google_compute_engine_email}",
     "serviceAccount:${local.service_agent_email}",
     "serviceAccount:${local.project_serivce_account}",
     "serviceAccount:${local.multi_tenant_cloud_build_account}",
     "serviceAccount:${local.multi_tenant_service_agent_email}",
  ]
  depends_on = [
    google_project_iam_binding.compute-security-admin,
    resource.google_project_iam_binding.gke-project-owner,
  ]
}

resource "google_project_iam_binding" "compute-security-admin" {
  project = var.vpc_host_project_name
  role    = "roles/compute.securityAdmin"

  members = [
    "serviceAccount:${local.service_agent_email}",
    "serviceAccount:${local.google_compute_engine_email}"
    #"serviceAccount:${resource.google_service_account.project_service_account.email}"
  ]
  depends_on = [
    google_project_iam_binding.gke-host-agent,
  ]
}

resource "google_project_iam_binding" "gke-host-agent" {
  project = var.vpc_host_project_name
  role    = "roles/container.hostServiceAgentUser"

  members = [
    "serviceAccount:${local.service_agent_email}",
    "serviceAccount:${local.multi_tenant_service_agent_email}",
    #"serviceAccount:${local.google_compute_engine_email}"
     #"serviceAccount:${resource.google_service_account.project_service_account.email}"
  ]

  depends_on = [
    module.create-gcp-project
  ]
}



## Added container service agent role to GKE service account 
resource "google_project_iam_binding" "gke-service-agent-role" {
  project = module.create-gcp-project.project.project_id
  role    = "roles/container.serviceAgent"

  members = [
    "serviceAccount:${local.service_agent_email}",
  ]

  depends_on = [
    module.create-gcp-project
  ]
}

### Impersonation of cloud build service account 

resource "google_project_iam_binding" "cloudbuild_token_creator" {
  project = data.google_project.host_project.project_id 
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
     "serviceAccount:${local.multi_tenant_cloud_build_account}",
  ]
  depends_on = [module.create-gcp-project]
}