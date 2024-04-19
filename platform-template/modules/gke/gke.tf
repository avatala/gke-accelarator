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

locals {
  # The following locals are derived from the subnet object
  # node_subnet        = var.subnet.name
  # pod_subnet         = var.subnet.secondary_ip_range[0].range_name
  # svc_subnet         = var.subnet.secondary_ip_range[local.suffix].range_name

  node_subnet        = var.subnet.name
  pod_subnet         = var.subnet.secondary_pod_subnet_name
  svc_subnet         = var.subnet.secondary_service_subnet_name

  region             = var.subnet.region
  
  #network            = split("/", var.subnet.network)[length(split("/", var.subnet.network)) - 1]
  # changed network name for the project.
  network            = var.subnet.network
  #network_project_id = var.subnet.project
  network_project_id = var.subnet.network_project_id
  suffix             = var.suffix
  env                = var.env
  # zone1              = var.zone[0]
  # zone2              = var.zone[1]
  # zone3              = var.zone[2]
}


data "google_compute_subnetwork" "sub_network" {
  name = var.subnet.name
  region = var.subnet.region
  project = var.subnet.network_project_id
}



# module "gke" {
#   source                   = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
#   #version                  = "13.0.0"
#   version                  = "5.0.0"
#   # changed project id 
#   project_id               = var.project_id
#   name                     = "gke-${local.env}-${local.region}"
#   regional                 = false
#   region                   = local.region
#   #zones                    = ["${local.region}-${local.zone1}","${local.region}-${local.zone2}","${local.region}-${local.zone3}"]
#   zones                    = ["${local.region}-${local.zone1}"]
#   release_channel          = "REGULAR"
#   network                  = local.network
#   subnetwork               = local.node_subnet
#   ## addding shared network project id 
#   network_project_id       = local.network_project_id
#   # ip_range_pods            = local.pod_subnet
#   # ip_range_services        = local.svc_subnet
#   ## changing for customer Yogesh Agrawal
#   ip_range_pods            = var.subnet.secondary_pod_subnet_name
#   ip_range_services        = var.subnet.secondary_service_subnet_name
#   remove_default_node_pool = true
#   horizontal_pod_autoscaling =  true
#   http_load_balancing      = true
#   cluster_resource_labels  = { "environ" : local.env, "region" : local.region }
#   #service_account           = var.service_account

#   node_pools = [
#     {
#       name         = "node-pool-01"
#       machine_type = "e2-medium"
#       min_count    = 3
#       max_count    = 6
#       auto_upgrade = true
#       node_count   = 3
#       node_locations = "${local.region}-${local.zone1}"
#     },
#   ]

# }



module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version                  = "22.0.0"
  project_id                 = var.project_id
  name                       = "gke-${local.env}-${local.region}"
  region                     = local.region
  #zones                      = ["${local.region}-${local.zone1}"]
  zones                      = var.zones
  network_project_id         = local.network_project_id
  network                    = local.network
  subnetwork                 = local.node_subnet
  ip_range_pods              = var.subnet.secondary_pod_subnet_name
  ip_range_services          = var.subnet.secondary_service_subnet_name
  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  regional                   = var.regional
  # kubernetes_dashboard       = true
  network_policy             = true
  create_service_account     = true
  #service_account            = var.service_account
  # istio = true
  cloudrun = false
  cluster_resource_labels  = { "environ" : local.env, "region" : local.region }
  remove_default_node_pool = true
  release_channel = "STABLE"
  node_pools = var.node_pools
  initial_node_count  = 2 
  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  master_authorized_networks =  [ 
    {
      cidr_block = data.google_compute_subnetwork.sub_network.ip_cidr_range
      display_name = "Subnet_access"
    },
    {
      cidr_block   = "35.235.240.0/20"
      display_name = "Google IAP access"
    }
  ]
}

