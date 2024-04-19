# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.






# module "gcp-project" {
#   source              = "terraform-google-modules/project-factory/google"
#   version             = "10.1.0"
#   random_project_id   = true
#   billing_account     = var.billing_account
#   name                = format("%s-%s",var.host_project_name,var.env)
#   org_id              = var.org_id
#   default_service_account = "keep"
#   folder_id           = var.folder_id
#   auto_create_network = false
#   activate_apis = [
#     "compute.googleapis.com",
#     "container.googleapis.com",
#     "iam.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "cloudbuild.googleapis.com",
#     "containerregistry.googleapis.com",
#     "secretmanager.googleapis.com",
#     "serviceusage.googleapis.com",
#     "gkehub.googleapis.com",
#     "anthosconfigmanagement.googleapis.com"
#   ]
# }



module "gcp-project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "13.0.0"
  random_project_id           = "true"
  #impersonate_service_account = var.impersonate_service_account
  activate_apis               = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "gkehub.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "iamcredentials.googleapis.com",
    "clouddeploy.googleapis.com"
  ]
  name                        = format("%s-%s",var.host_project_name,var.env)
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.folder_id
  svpc_host_project_id = var.vpc_type == "" ? "" : data.google_compute_network.shared_vpc.project
  shared_vpc_subnets   = var.vpc_type == "" ? [] : data.google_compute_network.shared_vpc.subnetworks_self_links # Optional: To enable subnetting, replace to "module.networking_project.subnetwork_self_link"
  default_service_account = "keep"
  labels = {
    environment       = var.env
    #application_name  = var.application_name
    #billing_code      = var.org_id
    # primary_contact   = element(split("@", var.primary_contact), 0)
    # secondary_contact = element(split("@", var.secondary_contact), 0)
    # business_code     = var.business_code
    vpc_type          = var.vpc_type
  }
  # budget_alert_pubsub_topic   = var.alert_pubsub_topic
  # budget_alert_spent_percents = var.alert_spent_percents
  # budget_amount               = var.budget_amount

}
