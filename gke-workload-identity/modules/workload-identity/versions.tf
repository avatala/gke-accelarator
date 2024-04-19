terraform {
  required_version = ">= 0.13.0"

  required_providers {
    # google = {
    #   source  = "hashicorp/google"
    #   version = ">= 3.39.0, < 5.0"
    # }
    kubernetes = {
      source  = "registry.terraform.io/hashicorp/kubernetes"
      #version = "~> 2.0"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-kubernetes-engine:workload-identity/v21.2.0"
  }
}