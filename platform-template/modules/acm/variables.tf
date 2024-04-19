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

variable "gke_cluster_id" {
  description = "GKE cluster id"
}

variable "env" {
  type = string
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
}

variable "project_id" {
  description = "GKE cluster name"
}

variable "git_user" {
  description = "git user"
}

variable "git_org" {
  description = "git org"
}

variable "acm_repo" {
  description = "ACM repo name"
}