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

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                    = "22.1.0"
  project_id                 = var.project_id
  name                       = "gke-p-${local.env}-${local.region}"
  region                     = local.region
  zones                      = var.zones
  network                    = local.network
  network_project_id         = local.network_project_id
  subnetwork                 = local.node_subnet
  ip_range_pods              = var.subnet.secondary_pod_subnet_name
  ip_range_services          = var.subnet.secondary_service_subnet_name
  regional                   = var.regional
  remove_default_node_pool   = true
  cluster_resource_labels    = { "environ" : local.env, "region" : local.region }
  release_channel            = "STABLE"
  http_load_balancing        = true
  create_service_account     = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = true
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "10.1.0.0/28"
  node_pools = var.node_pools
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
    }
  ] 

#   node_pools_labels = {
#     all = {}

#     default-node-pool = {
#       default-node-pool = true
#     }
#   }

#   node_pools_metadata = {
#     all = {}

#     default-node-pool = {
#       node-pool-metadata-custom-value = "my-node-pool"
#     }
#   }

#   node_pools_taints = {
#     all = []

#     default-node-pool = [
#       {
#         key    = "default-node-pool"
#         value  = true
#         effect = "PREFER_NO_SCHEDULE"
#       },
#     ]
#   }

#   node_pools_tags = {
#     all = []

#     default-node-pool = [
#       "default-node-pool",
#     ]
#   }
}
