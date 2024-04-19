variable "role_rolelist" {
    type = list(string)
}
variable "role_member" {}
variable "role_project" {}

resource "google_project_iam_member" "member-role" {
  for_each = toset(var.role_rolelist)
  role = each.key
  member = var.role_member
  project = var.role_project
}