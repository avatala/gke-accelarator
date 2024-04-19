# variable "suffix" {
#   type = number
# }

variable "env" {
  type = string
}

variable "gke_project_id" {
  type        = string
  description = "Project ID where GKE cluster is to be created."
}

variable "zone" {
  type        = list
  description = "zones to create GKE cluster in."
}

variable "node_pools" {
   type        = list(map(string))
   description = "List of maps containing node pools"
 }

variable "vpc_host_project_name" {}
variable "network_name" {}
variable "subnet_01_name" {}
variable "subnet_01_region" {}
variable "subnet_01_secondary_svc_1_name" {}
variable "subnet_01_secondary_pod_name" {}
#variable "regional" {}
