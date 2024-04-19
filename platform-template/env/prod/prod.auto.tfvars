project_id=  "YOUR_INFRA_PROJECT_ID"

group= "YOUR_IAM_GROUP"

billing_account= "YOUR_BILLING_ACCOUNT"

org_id= "YOUR_ORG_ID"

github_user= "YOUR_GITHUB_USER"

github_email= "YOUR_GITHUB_EMAIL"

github_org= "YOUR_GITHUB_ORG"

group_id= "YOUR_GROUP_ID"

folder_id= "YOUR_FOLDER_ID"

acm_repo= "YOUR_ACM_REPO"

env= "prod"

# this name is prefix for project name where GKE cluster is created
tf_service_account = "SLZ_TERRAFORM_INFRA_SERVICE_ACCOUNT"

gke_project_name= "YOUR_PROD_GKE_PROJECT_ID"

vpc_host_project_name = "YOUR_PROD_VPC_HOST_PROJECT_ID"

network_name= "YOUR_PROD_NETWORK_NAME"

routing_mode= "GLOBAL"

subnet_01_name= "YOUR_PROD_SUBNET_NAME"

subnet_01_region= "YOUR_PROD_SUBNET_REGION"

subnet_01_secondary_svc_1_name= "YOUR_PROD_SERVICE_SUBNET_NAME"

subnet_01_secondary_pod_name= "YOUR_PROD_POD_SUBNET_NAME"

regional   = true
zones = YOUR_PROD_ZONES
node_pools = [
     {
      name               = "node-pool-01"
      machine_type       = "YOUR_PROD_NODEPOOL_MACHINE_TYPE"
      min_count          = YOUR_PROD_NODEPOOL_MIN_COUNT
      max_count          = YOUR_PROD_NODEPOOL_MAX_COUNT
      disk_size_gb       = 100
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
     # initial_node_count = 1
     }
   ]
