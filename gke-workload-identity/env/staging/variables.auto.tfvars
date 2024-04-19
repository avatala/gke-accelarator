tf_service_account = "SLZ_TERRAFORM_INFRA_SERVICE_ACCOINT"

multi_tenant_project_id=  "YOUR_INFRA_PROJECT_ID"

env= "staging"
region = "us-central1"
app_sa = {
  "webpython" = { 
    name = "webpython"
    dev_app_project_name = "prj-d-app-infra-33ff"
    prod_app_project_name = "prj-p-app-infra-30a9"
    staging_app_project_name = "prj-st-app-infra-64f8"
    namespace = "default"
    roles = [   "roles/storage.admin", 
            "roles/cloudsql.client", 
            "roles/monitoring.admin", 
            "roles/logging.admin", 
            "roles/secretmanager.secretAccessor", 
            "roles/redis.editor",
            "roles/logging.logWriter",
        ]
  },
  "webgolang" = { 
    name = "webgolang"
    dev_app_project_name = "prj-d-app-infra-33ff"
    prod_app_project_name = "prj-p-app-infra-30a9"
    staging_app_project_name = "prj-st-app-infra-64f8"
    namespace = "default"
    roles = [   "roles/storage.admin", 
            "roles/cloudsql.client", 
            "roles/monitoring.admin", 
            "roles/logging.admin", 
            "roles/secretmanager.secretAccessor", 
            "roles/redis.editor",
            "roles/logging.logWriter",
        ]
  }
}
