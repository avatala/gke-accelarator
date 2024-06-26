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


variable "tf_service_account" {}

variable "multi_tenant_project_id" {
  description = "ID of your platform setup project/platform seed project"
}

variable "env" {}
variable "region" {}
 variable "app_sa" {
   type        = map
   description = "List of maps containing SA for application"
    default     = {
      "appname" = {
        name = ""
        dev_app_project_name  = "sample_project_name"
        prod_app_project_name  = "sample_project_name"
        staging_app_project_name  = "sample_project_name"
        namespace = "default"
        roles = []
      }
    }
 }



