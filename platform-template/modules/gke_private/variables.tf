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

# variable "subnet" {
#   type = object({
#     description              = string
#     gateway_address          = string
#     id                       = string
#     ip_cidr_range            = string
#     name                     = string
#     network                  = string
#     private_ip_google_access = string
#     project                  = string
#     region                   = string
#     secondary_ip_range = list(object({
#       ip_cidr_range = string
#       range_name    = string
#     }))
#     self_link = string
#   })
# }


variable "subnet" {
  type = object({
    description              = string
    gateway_address          = string
    id                       = string
    ip_cidr_range            = string
    name                     = string
    network                  = string
    private_ip_google_access = string
    project                  = string
    region                   = string
    self_link                 = string
    secondary_service_subnet_name = string
    secondary_pod_subnet_name = string
    network_project_id = string
  })
}

# variable "tf_service_account" {
#    type = string
#    default = ""
# }

# variable "service_account" {
#    type = string
# }
variable "suffix" {
  type = number
}

variable "env" {
  type = string
}

variable "project_id" {
  type        = string
  description = "Project ID where GKE cluster is to be created."
}

variable "zones" {
  type        = list
  description = "zones to create GKE cluster in."
}

variable "project_number" {
  type        = string
  description = "project number"
}


variable "node_pools" {
   type        = list(map(string))
   description = "List of maps containing node pools"
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
}
