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
variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
}
variable "zones" {
  type        = list
  description = "zones to create GKE cluster in."
}

variable "tf_service_account" {
   type = string
   default = ""
}

variable "project_id" {
  description = "ID of your platform setup project/platform seed project"
}
variable "group" {
  description = "IAM group"
}
variable "billing_account" {
  description = "GCP billing account"
}
variable "org_id" {
  description = "GCP org id"
}
variable "github_user" {}
variable "github_email" {}
variable "github_org" {}
variable "group_id" {
  description = "ID of the IAM group specified above"
}
variable "folder_id" {}
variable "acm_repo" {}
variable "env" {}
variable "gke_project_name" {
  description = "Name of the project that will host GKE cluster"
}
variable "network_name" {
  description = "VPC network where GKE cluster will be created"
}
variable "routing_mode" {}
variable "subnet_01_name" {}

variable "subnet_01_region" {}

variable "subnet_01_secondary_svc_1_name" {}

variable "subnet_01_secondary_pod_name" {}

variable "vpc_host_project_name" {
  description = "Name of the project that will host GKE cluster"
}


variable "node_pools" {
   type        = list(map(string))
   description = "List of maps containing node pools"
 }

 