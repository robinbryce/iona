resource "google_service_account" "gh-oidc" {
  for_each = {
    iona_app = ["robinbryce", "iona-app"]
  }
  account_id   = "gha-cd-${each.value[1]}"
  display_name = substr("GitHub Actions ${each.value[0]}/${each.value[1]}", 0, 100)
  project      = var.project
}

resource "google_project_iam_member" "gh-oidc" {
  project = var.project
  role = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/projects/871349271977/locations/global/workloadIdentityPools/github-oidc/attribute.repository/robinbryce/iona-app"
}

#resource "google_project_iam_custom_role" "imagepush" {
#  role_id = "imagepush"
#  title = "Role to enable GitHub Actions to push to the project container registry"
#  project = var.project
#
#  permissions = [
#    "storage.buckets.get",
#    "storage.objects.create",
#    "storage.objects.get",
#    "storage.objects.list"
#  ]
#}
#
## Note: the bucket for the registry host is created on first use in the
## project. this means that for a new project, this permission will be
## insufficient to push the first image. (push the first one by hand or create a
## special sa as storage.admin is very over powered)
#resource "google_project_iam_member" "gha-imagepush" {
#  project = var.project
#  role = "projects/${var.project}/roles/imagepush"
#  member = "serviceAccount:gha-cd-iona-app@${var.project}.iam.gserviceaccount.com"
#  depends_on = [google_project_iam_custom_role.imagepush]
#}

# XXX TODO need to depend on the sa above so it gets created first! applying
# twice fixes it for now
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.project
  pool_id     = "github-oidc"
  provider_id = "github-provider"
  provider_description = "Workload Identity Pool Provider for GitHub Actions based CD. A service account exists for each enabled repository, named after that repostiory gha-cd-<repo>"
  attribute_mapping = {
    "google.subject": "assertion.sub",
    "attribute.actor": "assertion.actor",
    "attribute.aud": "assertion.aud"#,
    #"attribute.repository": "assertion.repository"
  }
  sa_mapping = {
    "gha-cd-iona-app" = {
      sa_name   = "projects/${var.project}/serviceAccounts/gha-cd-iona-app@${var.project}.iam.gserviceaccount.com"
      # attribute = "attribute.repository/robinbryce/iona-app"
      attribute = "*"
    }
  }
}
