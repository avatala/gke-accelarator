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

resource "google_secret_manager_secret" "secret" {
  secret_id = var.secret_id
  replication {
    automatic = true
  }
  project = var.project_id
}

resource "google_secret_manager_secret_version" "secret-value" {
  provider = google
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret
}

resource "google_secret_manager_secret_iam_member" "secret-access-1" {
  provider = google

  secret_id = google_secret_manager_secret.secret.id
  role = "roles/secretmanager.secretAccessor"
  member =  format("%s:%s","group",var.group)
}

resource "google_secret_manager_secret_iam_member" "secret-access-2" {
  provider = google

  secret_id = google_secret_manager_secret.secret.id
  role = "roles/secretmanager.viewer"
  member = format("%s:%s","group",var.group)
}
