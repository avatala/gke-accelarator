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

resource "github_repository" "application_repo" {
    name = var.application_name
    description = "Application code repository for ${var.application_name}"

    visibility = "private"
    has_issues = false
    has_projects = false
    has_wiki = false

    allow_merge_commit = true
    allow_squash_merge = true
    allow_rebase_merge = true
    delete_branch_on_merge = false

    vulnerability_alerts = true
    template {
        owner      = "${var.org_name_to_clone_template_from}"
        repository = "app-template-${var.app_runtime}"
    }
}

resource "github_repository" "environment_repo" {
    name = "${var.application_name}-env"
    description = "Environment code repository for ${var.application_name}"

    visibility = "private"
    has_issues = false
    has_projects = false
    has_wiki = false

    allow_merge_commit = true
    allow_squash_merge = true
    allow_rebase_merge = true
    delete_branch_on_merge = false

    vulnerability_alerts = true
    template {
        owner      = "${var.org_name_to_clone_template_from}"
        repository = "env-template"
    }
}

resource "github_repository" "infrastructure_repo" {
    name = "${var.application_name}-infra"
    description = "Infrastructure as code repository for ${var.application_name}"

    visibility = "private"
    has_issues = false
    has_projects = false
    has_wiki = false

    allow_merge_commit = true
    allow_squash_merge = true
    allow_rebase_merge = true
    delete_branch_on_merge = false

    vulnerability_alerts = true
    template {
        owner      = "${var.org_name_to_clone_template_from}"
        repository = "infra-template"
    }

    provisioner "local-exec" {
        #command = " echo ${path.cwd} && ls -lrt ${path.cwd} && ls -lrt ../${path.cwd}  ${path.cwd}/prep-infra-repo.sh"
        command = "${path.module}/prep-infra-repo.sh ${var.org_name_to_clone_template_from} ${var.application_name} ${var.github_user} ${var.github_email} ${var.org_id} ${var.billing_account} ${var.state_bucket} ${var.folder_id}"
        //interpreter = ["bash"]
        //        script = [
        //            "${path.module}/prep-infra-repo.sh"
        //        ]
    }
}


resource "github_branch" "infrastructure_repo_staging" {
    repository = github_repository.infrastructure_repo.name
    branch     = "staging"
    source_branch = "dev"
    depends_on = [github_repository.infrastructure_repo]
}

resource "github_branch" "infrastructure_repo_prod" {
    repository = github_repository.infrastructure_repo.name
    branch     = "prod"
    source_branch = "dev"
    depends_on = [github_repository.infrastructure_repo]
}

//This is not working, need to fix it
//resource "github_branch_default" "infrastructure_repo_default"{
//    repository = github_repository.infrastructure_repo.name
//    branch     = "dev"
//    depends_on = [github_branch.infrastructure_repo_dev]
//}

resource "github_branch_protection_v3" "infrastructure_repo-prt-1" {
    repository = github_repository.infrastructure_repo.name
    branch = "staging"
    required_pull_request_reviews {
        //required_approving_review_count = 1
        require_code_owner_reviews = true
    }
    restrictions {

    }

    depends_on = [github_branch.infrastructure_repo_staging]
}

resource "github_branch_protection_v3" "infrastructure_repo-prt-2" {
    repository = github_repository.infrastructure_repo.name
    branch = "prod"
    required_pull_request_reviews {
        //required_approving_review_count = 1
        require_code_owner_reviews = true
    }
    restrictions {

    }

    depends_on = [github_branch.infrastructure_repo_prod]
}