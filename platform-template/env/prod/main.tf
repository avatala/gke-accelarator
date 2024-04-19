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
  # description = [for item in module.create-vpc.network.subnets : item.description]
  # gateway_address = [for item in module.create-vpc.network.subnets : item.gateway_address]
  # id = [for item in module.create-vpc.network.subnets : item.id]
  # ip_cidr_range = [for item in module.create-vpc.network.subnets : item.ip_cidr_range]
  # name = [for item in module.create-vpc.network.subnets : item.name]
  # network = [for item in module.create-vpc.network.subnets : item.network]
  # private_ip_google_access = [for item in module.create-vpc.network.subnets : item.private_ip_google_access]
  # project = [for item in module.create-vpc.network.subnets : item.project]
  # region = [for item in module.create-vpc.network.subnets : item.region]
  # secondary_ip_range =  [for item in module.create-vpc.network.subnets : [ for i in item.secondary_ip_range : { ip_cidr_range =  i.ip_cidr_range  , range_name =  i.range_name } ] ]
  # self_link = [for item in module.create-vpc.network.subnets : item.self_link]
  # #subnet1 = {description = local.description[0] , gateway_address = local.gateway_address[0], id = local.id[0] ,ip_cidr_range = local.ip_cidr_range[0], name = local.name[0] , network = local.network[0] , private_ip_google_access = local.private_ip_google_access[0] , project = local.project[0] , region = local.region[0] , self_link = local.self_link[0] , secondary_ip_range = local.secondary_ip_range[0]  }
  
  subnet1 = { description = "" , 
              gateway_address = "",
              id = data.google_compute_subnetwork.sub_network.id , 
              ip_cidr_range ="", 
              name = var.subnet_01_name , 
              network = var.network_name, 
              private_ip_google_access = "", 
              project = var.gke_project_name , 
              network_project_id = var.vpc_host_project_name,  
              region = var.subnet_01_region , 
              self_link = data.google_compute_subnetwork.sub_network.self_link , 
              secondary_pod_subnet_name = var.subnet_01_secondary_pod_name , 
              secondary_service_subnet_name = var.subnet_01_secondary_svc_1_name }

  #subnet2 = {description = local.description[1] , gateway_address = local.gateway_address[1], id = local.id[1] ,ip_cidr_range = local.ip_cidr_range[1], name = local.name[1] , network = local.network[1] , private_ip_google_access = local.private_ip_google_access[1] , project = local.project[1] , region = local.region[1] , self_link = local.self_link[1] , secondary_ip_range = local.secondary_ip_range[1]  }
  gke_cluster_id = format("projects/%s/locations/%s/clusters/%s",module.create-gcp-project.project.project_id,module.create_gke_1.cluster_name.location,module.create_gke_1.cluster_name.name)

}


data "google_compute_network" "vpc_network" {
  name = var.network_name
  project = var.vpc_host_project_name
}


data "google_compute_subnetwork" "sub_network" {
  name = var.subnet_01_name
  region = var.subnet_01_region
  project = var.vpc_host_project_name
}

module "create-gcp-project" {
  source = "../../modules/project/"
  host_project_name = var.gke_project_name
  billing_account = var.billing_account
  org_id = var.org_id
  folder_id = var.folder_id
  env = var.env
  network_name = var.network_name
  vpc_host_project_name = var.vpc_host_project_name
  #impersonate_service_account = var.tf_service_account
  vpc_type                    = "base"
}

# Create GKE zonal cluster in platform_admin project using subnet-01 zone a
module "create_gke_1" {
  source            = "../../modules/gke/"
  subnet            = local.subnet1
  project_id        = module.create-gcp-project.project.project_id
  suffix            = "1"
  zones              = var.zones
  regional          = var.regional
  env               = var.env
  project_number    = module.create-gcp-project.project.project_number
  node_pools        = var.node_pools
  #service_account   = module.create-gcp-project.project.service_account_email
  depends_on        = [
                        resource.google_project_iam_binding.compute-networkuser
                      ]
}




# module "create_gke_1" {
#   source            = "../../modules/gke/"
#   env               = var.env
#   gke_project_id    = module.create-gcp-project.project.project_id
#   zone              = var.zone
#   vpc_host_project_name = var.vpc_host_project_name
#   network_name = var.network_name
#   subnet_01_name = var.subnet_01_name
#   subnet_01_region = var.subnet_01_region
#   subnet_01_secondary_svc_1_name = var.subnet_01_secondary_svc_1_name
#   subnet_01_secondary_pod_name = var.subnet_01_secondary_pod_name
#   node_pools        = var.node_pools
  
#   #service_account   = module.create-gcp-project.project.service_account_email

#   depends_on        = [
#                         resource.google_project_iam_binding.compute-networkuser
#                       ]
# }


module "secret-gke-name" {
  source            = "../../modules/secrets/"
  //secret            = module.create_gke_1.name.name
  secret            =  local.gke_cluster_id
  secret_id         = "${var.env}-gke-cluster-1"
  project_id        =  var.project_id
  group             =  var.group
}


module "secret-gke-sa" {
  source            = "../../modules/secrets/"
  #secret            =  "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  secret            =  module.create_gke_1.cluster_name.service_account
  secret_id         = "${var.env}-gke-sa"
  project_id        =  var.project_id
  group             =  var.group
}

module "secret-gke-ca" {
  source            = "../../modules/secrets/"
  #secret            =  google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
  secret            =  module.create_gke_1.cluster_name.ca_certificate
  secret_id         = "${var.env}-gke-ca"
  project_id        =  var.project_id
  group             =  var.group
}

  
module "secret-gke-endpoint" {
  source            = "../../modules/secrets/"
  #secret            =  google_container_cluster.gke_cluster.endpoint
  secret            =  module.create_gke_1.cluster_name.endpoint
  secret_id         = "${var.env}-gke-endpoint"
  project_id        =  var.project_id
  group             =  var.group
}

  

# module "acm" {
#   source                = "../../modules/acm/"
#   gke_cluster_id        = local.gke_cluster_id
#   gke_cluster_name      = module.create_gke_1.cluster_name.name
#   env                   = var.env
#   project_id            = module.create-gcp-project.project.project_id
#   git_user              = var.github_user
#   git_org               = var.github_org
#   acm_repo              = var.acm_repo
# }
