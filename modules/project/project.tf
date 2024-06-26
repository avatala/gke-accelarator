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

module "gcp-project" {
  source              = "terraform-google-modules/project-factory/google"
  version             = "10.1.0"
  random_project_id   = true
  billing_account     = var.billing_account
  name                = format("%s-%s",var.host_project_name,var.env)
  org_id              = var.org_id
  default_service_account = "keep"
  folder_id           = var.folder_id
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",

  ]
}
