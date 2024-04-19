/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


 locals {
   gke_project_id = element(split("/",data.google_secret_manager_secret_version.gke_cluster_name.secret_data),1)
    gke_cluster_name = element(split("/",data.google_secret_manager_secret_version.gke_cluster_name.secret_data),5)
 }

provider "kubernetes" {
  host                   = "https://${data.google_secret_manager_secret_version.gke_cluster_endpoint.secret_data}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_secret_manager_secret_version.gke_cluster_ca_certificate.secret_data)
}

data "google_client_config" "default" {}

data "google_secret_manager_secret_version" "gke_cluster_name" {
  secret = "${var.env}-gke-cluster-1"
  project = var.multi_tenant_project_id
}

data "google_secret_manager_secret_version" "gke_cluster_endpoint" {
  secret = "${var.env}-gke-endpoint"
  project = var.multi_tenant_project_id
}

data "google_secret_manager_secret_version" "gke_cluster_ca_certificate" {
  secret = "${var.env}-gke-ca"
  project = var.multi_tenant_project_id
}

resource "google_service_account" "workload_service_account" {
  for_each = var.app_sa
  account_id   = "sa-${each.key}"
  display_name = "SA for workload identity"
  project      = each.value["dev_app_project_name"]
}


resource "google_project_iam_member" "SA-grant-access-role" {
  for_each = var.app_sa
  role = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${google_service_account.workload_service_account[each.key].email}"
  project = local.gke_project_id
}


module grant_iam_project_role {
  source = "../../modules/iam_roles"
  for_each = var.app_sa
    role_member = "serviceAccount:${google_service_account.workload_service_account[each.key].email}"
    role_rolelist = each.value.roles
    role_project = each.value["${var.env}_app_project_name"]
    depends_on = [google_service_account.workload_service_account]
}



module "workload_identity" {
  for_each = var.app_sa
  source              = "../../modules/workload-identity/"
  project_id          = each.value["${var.env}_app_project_name"]
  gke_project_id      = local.gke_project_id
  name                = "sa-${each.key}"
  #impersonate_service_account = "cloud-deploy-lk7z@webpython-tf-project-e188.iam.gserviceaccount.com"
  #name              = "workload-sa-test1"
  #gcp_sa_name      = "sa-${each.key}"
  use_existing_gcp_sa = true
  use_existing_k8s_sa = false
  #cluster_name                    = data.google_container_cluster.my_cluster.name
  cluster_name                    = local.gke_cluster_name
  #location                        = module.create_gke_1.region
  location                        = var.region
  namespace                       = each.value["namespace"]
  automount_service_account_token = true
  annotate_k8s_sa                 = true
  depends_on = [
    google_service_account.workload_service_account, 
  ]
  #roles                           = each.value["roles"]
}
