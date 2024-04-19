#!/bin/sh
# Copyright 2019 Google LLC
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
github_org=${1}
application_name=${2}
github_user=${3}
github_email=${4}
org_id=${5}
billing_account=${6}
state_bucket=${7}
folder_id=${8}

repo=${application_name}-infra
git clone -b dev https://github.com/${github_org}/${repo} ${repo}
cd ${repo}
#git checkout dev
#ls -lrt
find . -type f -name variables.tf -exec  sed -i "s/YOUR_BILLING_ACCOUNT/${billing_account}/g" {} +
find . -type f -name variables.tf -exec  sed -i "s/YOUR_ORG_ID/${org_id}/g" {} +
find . -type f -name variables.tf -exec  sed -i "s/YOUR_GITHUB_USER/${github_user}/g" {} +
find . -type f -name variables.tf -exec  sed -i "s/YOUR_GITHUB_EMAIL/${github_email}/g" {} +
find . -type f -name variables.tf -exec  sed -i "s/YOUR_GITHUB_ORG/${github_org}/g" {} +
find . -type f -name variables.tf -exec  sed -i "s/YOUR_FOLDER_ID/${folder_id}/g" {} +
find . -type f -name variables.tf -exec  sed -i "s/YOUR_PROJECT_NAME/${application_name}/g" {} +
find . -type f -name backend.tf -exec  sed -i "s/YOUR_TERRAFORM_STATE_BUCKET/${state_bucket}/g" {} +
find . -type f -name backend.tf -exec  sed -i "s/YOUR_APPLICATION/${application_name}/g" {} +

#find . -type f -name variables.tf -exec git add .
git add .
git config --global user.name ${github_user}
git config --global user.email ${github_email}
git commit -m "Setting up infra repo."
git push origin

#Create staging and prod branches
#git branch staging
#git push -u origin staging
#git branch prod
#git push -u origin prod
#git config --global user.name gushob21
#git config --global user.email gushob21@github.com
#git commit -m "Creating new branches"
#git push origin
