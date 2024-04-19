/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "google_project" "YOUR_APPLICATION_NAME_seed_project" {
  project_id = "YOUR_SEED_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-user" {
  secret = "github-user"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-email" {
  secret = "github-email"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-billingac" {
  secret = "gcp-billingac"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-org" {
  secret = "github-org"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-org" {
  secret = "gcp-org"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-folder" {
  secret = "gcp-folder"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_group-id" {
  secret = "group-id"
  project = "YOUR_INFRA_PROJECT_ID"
}


//Look up all the secrets from the infrastructure project


locals {
  YOUR_APPLICATION_NAME_cloud_build_email = format("%s@%s",module.YOUR_APP_PROJECT_NAME.project_number,"cloudbuild.gserviceaccount.com")
  seed_project_cloudbuild_email_YOUR_APPLICATION_NAME = format("%s@%s",data.google_project.YOUR_APPLICATION_NAME_seed_project.number,"cloudbuild.gserviceaccount.com")
}
/*
module "YOUR_APPLICATION_NAME-iac-state-bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  //version = "~> 1.3"
  name       = join("-", [module.YOUR_APP_PROJECT_NAME.project_id,"infra-tf"])
  project_id = module.YOUR_APP_PROJECT_NAME.project_id
  location   = "us-east1"
  iam_members = [{
        role   = "roles/storage.objectViewer"
        member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
  }]
}
*/
resource "google_storage_bucket" "YOUR_APPLICATION_NAME-iac-state-bucket" {
  name                        = join("-", [module.YOUR_APP_PROJECT_NAME.project_id,"infra-tf"])
  project                     = module.YOUR_APP_PROJECT_NAME.project_id
  location                    = "us-east1"
  storage_class               = null
  uniform_bucket_level_access = true
  labels                      = null
  force_destroy               = true
}

resource "google_storage_bucket_iam_member" "YOUR_APPLICATION_NAME-b-members-1" {
  bucket = google_storage_bucket.YOUR_APPLICATION_NAME-iac-state-bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

resource "google_storage_bucket_iam_member" "YOUR_APPLICATION_NAME-b-members-2" {
  bucket = google_storage_bucket.YOUR_APPLICATION_NAME-iac-state-bucket.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

module "YOUR_APPLICATION_NAME" {
    source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//manage-repos"
    org_name_to_clone_template_from = "GITHUB_ORG_TO_CLONE_TEMPLATES_FROM"
    app_runtime = "YOUR_APPLICATION_RUNTIME"
    application_name = "YOUR_APPLICATION_NAME"
    github_user = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
    github_email = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
    org_id = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
    billing_account = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-billingac.secret_data
    folder_id = "YOUR_GCP_FOLDER_ID"
    state_bucket = google_storage_bucket.YOUR_APPLICATION_NAME-iac-state-bucket.name


}

//Create Project
module "YOUR_APP_PROJECT_NAME" {
    source              = "terraform-google-modules/project-factory/google"
    version             = "10.1.0"
    random_project_id   = true
    billing_account     = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-billingac.secret_data
    name                = "YOUR_APP_PROJECT"
    org_id              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
    folder_id           = "YOUR_GCP_FOLDER_ID"
    default_service_account = "keep"
    activate_apis = [
        "compute.googleapis.com",
        "container.googleapis.com",
        "iam.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "cloudbuild.googleapis.com",
        "containerregistry.googleapis.com",
        "secretmanager.googleapis.com",
        "serviceusage.googleapis.com",
        "cloudbilling.googleapis.com"
    ]
}

//Grant CB SA access to create new project(ian trigger)
resource "google_organization_iam_member" "YOUR_APPLICATION_NAME-billing-user" {
  count   = var.create_service_account ? 1 : 0
  org_id  = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
  role    = "roles/billing.user"
  member  = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

resource "google_organization_iam_member" "YOUR_APPLICATION_NAME-project-creator" {
  count   = var.create_service_account ? 1 : 0
  org_id  = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
  role    = "roles/resourcemanager.projectCreator"
  member  = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

/*
//Create VPC
module "YOUR_APPLICATION_NAME-VPC" {
    source  = "terraform-google-modules/network/google"
    version = "~> 3.0"
    project_id                             = module.YOUR_APP_PROJECT_NAME.project_id
    network_name                           = var.network_name
    subnets = [
        {
            subnet_name   = "${var.network_name}-subnet-01"
            subnet_ip     = "10.10.10.0/24"
            subnet_region = "us-west1"
        },
        {
            subnet_name           = "${var.network_name}-subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-west1"
        },
    ]

    secondary_ranges = {
        "${var.network_name}-subnet-01" = [
            {
                range_name    = "${var.network_name}-subnet-01-01"
                ip_cidr_range = "192.168.64.0/24"
            },
            {
                range_name    = "${var.network_name}-subnet-01-02"
               ip_cidr_range = "192.168.65.0/24"
            },
        ]

        "${var.network_name}-subnet-02" = [
            {
                range_name    = "${var.network_name}-subnet-02-01"
                ip_cidr_range = "192.168.66.0/24"
            },
        ]
    }
}

*/


// Create Service Account for Cloud deploy and grant it permissions including permission to deploy to target GKE cluster
resource "random_string" "YOUR_APPLICATION_NAME_cloud_deploy_service_account_suffix" {
  upper   = false
  lower   = true
  special = false
  length  = 4
}

resource "random_string" "YOUR_APPLICATION_NAME_secret_suffix" {
  upper   = true
  lower   = true
  special = true
  length  = 8
}

resource "google_service_account" "YOUR_APPLICATION_NAME_cloud_deploy_service_account" {
  count        = var.create_service_account ? 1 : 0
  project      = module.YOUR_APP_PROJECT_NAME.project_id
  account_id   = "cloud-deploy-${random_string.YOUR_APPLICATION_NAME_cloud_deploy_service_account_suffix.result}"
  display_name = "Terraform-managed service account for cloud deploy"
}

resource "google_project_iam_member" "YOUR_APPLICATION_NAME_cloud_deploy_service_account-log_writer" {
  count   = var.create_service_account ? 1 : 0
  project = module.YOUR_APP_PROJECT_NAME.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.YOUR_APPLICATION_NAME_cloud_deploy_service_account[0].email}"
}


resource "google_project_iam_member" "YOUR_APPLICATION_NAME_cloud_deploy_service_account-job_runner" {
  count   = var.create_service_account ? 1 : 0
  project = module.YOUR_APP_PROJECT_NAME.project_id
  role    = "roles/clouddeploy.jobRunner"
  member  = "serviceAccount:${google_service_account.YOUR_APPLICATION_NAME_cloud_deploy_service_account[0].email}"
}


//Add cloud deploy account to the google group that allows it to deploy to gke cluster in platform project
resource "google_cloud_identity_group_membership" "YOUR_APPLICATION_NAME_managers" {
  provider = google.impersonated
  group    = format("%s/%s","groups",data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_group-id.secret_data)
  preferred_member_key { id = google_service_account.YOUR_APPLICATION_NAME_cloud_deploy_service_account[0].email }

  # MEMBER role must be specified. The order of roles should not be changed.
  roles { name = "MEMBER" }
  roles { name = "MANAGER" }
}


resource "google_project_iam_member" "YOUR_APPLICATION_NAME_cloud_deploy_service_account-storage_viewer" {
  count   = var.create_service_account ? 1 : 0
  project = module.YOUR_APP_PROJECT_NAME.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.YOUR_APPLICATION_NAME_cloud_deploy_service_account[0].email}"
}


//TODO: cut short editor access on cloudbuild SA

resource "google_project_iam_member" "YOUR_APPLICATION_NAME_editor" {
  project = module.YOUR_APP_PROJECT_NAME.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//TODO : probably dupplicate. check and remove
resource "google_project_iam_member" "YOUR_APPLICATION_NAME_editor_add_github_sercret_perm" {
  project = module.YOUR_APPLICATION_NAME-project.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//impersonation not required to read the secret from infra project as the CB SA is an owner of the group
//get the cluster names for all environments and create secrets in app tf project to hold those names
data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_dev-gke-1" {
  secret = "dev-gke-cluster-1"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_staging-gke-1" {
  secret = "staging-gke-cluster-1"
  project = "YOUR_INFRA_PROJECT_ID"
}


data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_prod-gke-1" {
  secret = "prod-gke-cluster-1"
  project = "YOUR_INFRA_PROJECT_ID"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_dev-gke-name-1" {
  secret_id = "dev-gke-cluster-1"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_dev-gke-name-1-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_dev-gke-name-1.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_dev-gke-1.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_dev-gke-name-1-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_dev-gke-name-1.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_staging-gke-name-1" {
  secret_id = "staging-gke-cluster-1"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_staging-gke-name-1-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_staging-gke-name-1.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_staging-gke-1.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_staging-gke-name-1-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_staging-gke-name-1.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_prod-gke-name-1" {
  secret_id = "prod-gke-cluster-1"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_prod-gke-name-1-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_prod-gke-name-1.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_prod-gke-1.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_prod-gke-name-1-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_prod-gke-name-1.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Fetch github token from secretsmanager and add it to a secret in app tf project
data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github" {
  secret = "github-token"
  project = "YOUR_INFRA_PROJECT_ID"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_github-token" {
  secret_id = "github-token"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-token-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-token.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_github-token-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-token.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store github user in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_github-user" {
  secret_id = "github-user"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-user-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-user.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_github-user-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-user.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store github org in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_github-org" {
  secret_id = "github-org"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-org-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-org.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-org.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_github-org-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-org.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store github email in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_github-email" {
  secret_id = "github-email"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-email-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-email.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_github-email-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_github-email.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store gcp org in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_gcp-org" {
  secret_id = "gcp-org"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-org-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_gcp-org.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_gcp-org-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_gcp-org.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store billing account in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_gcp-billingac" {
  secret_id = "gcp-billingac"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-billingac-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_gcp-billingac.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-billingac.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_gcp-billingac-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_gcp-billingac.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store app name in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_app-name" {
  secret_id = "app-name"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_app-name-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_app-name.id
  secret_data = "YOUR_APPLICATION_NAME"
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_app-name-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_app-name.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store env repo name in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_env-repo" {
  secret_id = "env-repo"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_env-repo-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_env-repo.id
  secret_data = "YOUR_APPLICATION_NAME-env"
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_env-repo-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_env-repo.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Store cloud deploy SA in secretsmanager in app tf project
resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_clouddeploy-sa" {
  secret_id = "clouddeploy-sa"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_clouddeploy-sa-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_clouddeploy-sa.id
  secret_data = "${google_service_account.YOUR_APPLICATION_NAME_cloud_deploy_service_account[0].email}"
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_clouddeploy-sa-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_clouddeploy-sa.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Fetch dev gke sa and store it in secretsmanager in app tf project

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_dev-gke-sa-infra" {
  secret = "dev-gke-sa"
  project = "YOUR_INFRA_PROJECT_ID"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_dev-gke-sa" {
  secret_id = "dev-gke-sa"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_dev-gke-sa-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_dev-gke-sa.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_dev-gke-sa-infra.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_dev-gke-sa-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_dev-gke-sa.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Fetch staging gke sa and store it in secretsmanager in app tf project

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_staging-gke-sa-infra" {
  secret = "staging-gke-sa"
  project = "YOUR_INFRA_PROJECT_ID"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_staging-gke-sa" {
  secret_id = "staging-gke-sa"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_staging-gke-sa-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_staging-gke-sa.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_staging-gke-sa-infra.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_staging-gke-sa-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_staging-gke-sa.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Fetch prod gke sa and store it in secretsmanager in app tf project

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_prod-gke-sa-infra" {
  secret = "prod-gke-sa"
  project = "YOUR_INFRA_PROJECT_ID"
}

resource "google_secret_manager_secret" "YOUR_APPLICATION_NAME_prod-gke-sa" {
  secret_id = "prod-gke-sa"
  replication {
    automatic = true
  }
  project = module.YOUR_APP_PROJECT_NAME.project_id
}

resource "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_prod-gke-sa-secret" {
  provider = google
  secret      = google_secret_manager_secret.YOUR_APPLICATION_NAME_prod-gke-sa.id
  secret_data = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_prod-gke-sa-infra.secret_data
}

resource "google_secret_manager_secret_iam_member" "YOUR_APPLICATION_NAME_prod-gke-sa-secret-access" {
  provider = google
  secret_id = google_secret_manager_secret.YOUR_APPLICATION_NAME_prod-gke-sa.id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${local.YOUR_APPLICATION_NAME_cloud_build_email}"
}

//Create cloudbuild trigger to create cloud deploy app
resource "google_cloudbuild_trigger" "YOUR_APPLICATION_NAME_trigger-app" {
  name     = "deploy-app"
  project = module.YOUR_APP_PROJECT_NAME.project_id
  description = "Trigger to start cloud deploy that will deploy the app"
  filename = "cloudbuild.yaml"
  github {
    owner = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-org.secret_data
    name = "YOUR_APPLICATION_NAME"
    push {
      branch = "main"
    }
  }
}


//Create cloudbuild trigger to create cloud deploy infra for the app
resource "google_cloudbuild_trigger" "YOUR_APPLICATION_NAME_trigger-infra" {
  name     = "deploy-infra"
  project = module.YOUR_APP_PROJECT_NAME.project_id
  description = "Trigger to deploy the infrastructure for the app"
  filename = "cloudbuild.yaml"
  github {
    owner = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-org.secret_data
    name = "YOUR_APPLICATION_NAME-infra"
    push {
      branch = ".*"
    }
  }
  depends_on = [module.YOUR_APPLICATION_NAME]
}

