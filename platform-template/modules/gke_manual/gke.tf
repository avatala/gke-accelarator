

data "google_compute_network" "vpc_network1" {
  name = var.network_name # "vpc-d1-shared-base"
  project = var.vpc_host_project_name
}


data "google_compute_subnetwork" "sub_network1" {
  name = var.subnet_01_name # "sb-d1-shared-us-west1-subnet1"
  region = var.subnet_01_region
  project = var.vpc_host_project_name
}


resource "google_container_cluster" "gke_cluster" {
  name                     = "gke-${var.env}-${var.subnet_01_region}"
  location                 = var.subnet_01_region
  node_locations           = var.zone
  project                  = var.gke_project_id
  remove_default_node_pool = true
  initial_node_count       = 2
  network                  = data.google_compute_network.vpc_network1.id
  subnetwork               = data.google_compute_subnetwork.sub_network1.id

  logging_service = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  enable_intranode_visibility = true

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.gke_project_id}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.subnet_01_secondary_pod_name
    services_secondary_range_name =  var.subnet_01_secondary_svc_1_name
  }
    # IAP ip address 35.235.240.0/20
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = data.google_compute_subnetwork.sub_network1.ip_cidr_range
      display_name = "internal_access"
    }
    cidr_blocks {
        cidr_block   = "35.235.240.0/20"
        display_name = "Google IAP access"
    }
  }  

}

resource "google_container_node_pool" "node_pool" {
  count = length(var.node_pools)
  name       = var.node_pools[count.index].name
  cluster    = google_container_cluster.gke_cluster.id
  node_count = var.node_pools[count.index].min_count

  management {
    auto_repair  = var.node_pools[count.index].auto_repair
    auto_upgrade = var.node_pools[count.index].auto_upgrade
  }

  autoscaling {
    min_node_count = var.node_pools[count.index].min_count
    max_node_count = var.node_pools[count.index].max_count
  }

  node_config {
    preemptible  = var.node_pools[count.index].preemptible
    machine_type = var.node_pools[count.index].machine_type

    # service_account = google_service_account.default.email

    labels = {
      role = "general"
    }

    tags = ["gke-tag"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

