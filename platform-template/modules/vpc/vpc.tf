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

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "3.0.1"

  project_id      = var.project_id
  network_name    = var.network_name
  routing_mode    = var.routing_mode
  //shared_vpc_host = true

  subnets = [
    {
      subnet_name      = var.subnet_01_name
      subnet_ip        = var.subnet_01_ip
      subnet_region    = var.subnet_01_region
      subnet_flow_logs = "true"
      description      = var.subnet_01_description
    },
    {
      subnet_name      = var.subnet_02_name
      subnet_ip        = var.subnet_02_ip
      subnet_region    = var.subnet_02_region
      subnet_flow_logs = "true"
      description      = var.subnet_02_description
    },
  ]

  secondary_ranges = {
    "${var.subnet_01_name}" = [
      {
        range_name    = var.subnet_01_secondary_svc_1_name
        ip_cidr_range = var.subnet_01_secondary_svc_1_range
      },
      {
        range_name    = var.subnet_01_secondary_svc_2_name
        ip_cidr_range = var.subnet_01_secondary_svc_2_range
      },
      {
        range_name    = var.subnet_01_secondary_pod_name
        ip_cidr_range = var.subnet_01_secondary_pod_range
      },
    ]
    "${var.subnet_02_name}" = [
      {
        range_name    = var.subnet_02_secondary_svc_1_name
        ip_cidr_range = var.subnet_02_secondary_svc_1_range
      },
      {
        range_name    = var.subnet_02_secondary_svc_2_name
        ip_cidr_range = var.subnet_02_secondary_svc_2_range
      },
      {
        range_name    = var.subnet_02_secondary_pod_name
        ip_cidr_range = var.subnet_02_secondary_pod_range
      },
    ]
  }
}





# module "vpc-new" {
#   source  = "terraform-google-modules/network/google"
#   version = "3.0.1"

#   project_id      = "ya2-multi-tenant-prj-6vye0m"
#   network_name    = "gke-shared-vpc-network-dev"
#   routing_mode    = "GLOBAL"
#   //shared_vpc_host = true

#   subnets = [
#     {
#       subnet_name      = "subnet1-d-us-central1"
#       subnet_ip        = "10.10.0.0/22"
#       subnet_region    = "us-central1"
#       subnet_flow_logs = "false"
#       description      = "Internal subnet"
#     },
#     {
#       subnet_name      = "subnet2-d-us-central1"
#       subnet_ip        = "10.20.0.0/22"
#       subnet_region    = "us-central1"
#       subnet_flow_logs = "false"
#       description      = "Internal subnet"
#     },
#   ]

#   secondary_ranges = {
#     "subnet1-d-us-central1" = [
#       {
#         range_name    = "subnet-01-service-01-name"
#         ip_cidr_range = "10.5.0.0/20"
#       },
#       {
#         range_name    = "subnet-01-service-02-name"
#         ip_cidr_range = "10.5.16.0/20"
#       },
#       {
#         range_name    = "subnet-01-secondary-pod-name"
#         ip_cidr_range = "10.0.0.0/14"
#       },
#     ]
#     "subnet2-d-us-central1" = [
#       {
#         range_name    = "subnet-02-service-01-name"
#         ip_cidr_range = "	10.13.0.0/20"
#       },
#       {
#         range_name    = "subnet-02-service-02-name"
#         ip_cidr_range = "	10.13.16.0/20"
#       },
#       {
#         range_name    = "subnet-02-secondary-pod-name"
#         ip_cidr_range = "10.8.0.0/14"
#       },
#     ]
#   }
# }









//# create firewall rules to allow-all inernally
//module "net-firewall" {
//  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
//  version                 = "3.0.1"
//  project_id              = var.project_id
//  network                 = module.shared_vpc.network_name
//  internal_ranges_enabled = true
//  internal_ranges         = ["10.0.0.0/8"]
//  internal_allow = [
//    { "protocol" : "all" },
//  ]
//}