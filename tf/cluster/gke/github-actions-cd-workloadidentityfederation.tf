
locals {
  repositories = {
    iona_app = ["robinbryce", "iona-app"]
    tokenator = ["robinbryce", "tokenator"]
  }
}

resource "google_service_account" "gh-oidc" {

  for_each = local.repositories
  account_id   = "gha-cd-${each.value[1]}"
  display_name = substr("GitHub Actions ${each.value[0]}/${each.value[1]}", 0, 100)
  project      = var.project
}

resource "google_project_iam_member" "gh-oidc" {
  for_each = local.repositories
  project = var.project
  role = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/projects/871349271977/locations/global/workloadIdentityPools/github-oidc/attribute.repository/robinbryce/${each.value[1]}"
}

resource "google_project_iam_custom_role" "imagepush" {
  role_id = "imagepush"
  title = "Role to enable GitHub Actions to push to the project container registry"
  project = var.project

  permissions = [
    "storage.buckets.get",
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.list"
  ]
}

# Note: the bucket for the registry host is created on first use in the
# project. this means that for a new project, this permission will be
# insufficient to push the first image. (push the first one by hand or create a
# special sa as storage.admin is very over powered)
resource "google_project_iam_member" "gha-imagepush" {
  for_each = local.repositories

  project = var.project
  role = "projects/${var.project}/roles/imagepush"
  member = "serviceAccount:gha-cd-${each.value[1]}@${var.project}.iam.gserviceaccount.com"
  depends_on = [google_project_iam_custom_role.imagepush]
}
