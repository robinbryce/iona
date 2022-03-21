# I think we want to manage the repos, and the workload identity pool for them, in their own workspace
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
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.repository/${each.value[0]}/${each.value[1]}"
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

resource "google_project_iam_member" "gha-objectcreator" {
  for_each = local.repositories

  project = var.project
  # role = "projects/${var.project}/roles/imagepush"
  role = "roles/storage.objectCreator"
  member = "serviceAccount:gha-cd-${each.value[1]}@${var.project}.iam.gserviceaccount.com"
  # depends_on = [google_project_iam_custom_role.imagepush]
}

resource "google_project_iam_member" "gha-objectviewer" {
  for_each = local.repositories

  project = var.project
  # role = "projects/${var.project}/roles/imagepush"
  role = "roles/storage.objectViewer"
  member = "serviceAccount:gha-cd-${each.value[1]}@${var.project}.iam.gserviceaccount.com"
  # depends_on = [google_project_iam_custom_role.imagepush]
}

# hack around the fact that pools don't like to be re-created
resource "google_iam_workload_identity_pool" "main" {
  provider                  = google-beta
  project                   = var.project
  workload_identity_pool_id = "github-oidc-1"  # can't be deleted & re-created so we need to change the name
  display_name              = "github-oidc"
  description               = "Workload Identity Pool managed by Terraform"
  disabled                  = false
}

#locals {
#  wif_pool_id = "projects/iona-1/locations/global/workloadIdentityPools/github-oidc"
#  wif_pool_numeric_id = "projects/871349271977/locations/global/workloadIdentityPools/github-oidc"
#}

resource "google_iam_workload_identity_pool_provider" "main" {
  provider                           = google-beta
  project                            = var.project
  # hack around the fact that pools don't like to be re-created
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "github-provider"
  description                        = "Workload Identity Pool Provider for GitHub Actions based CD. A service account exists for each enabled repository, named after that repostiory gha-cd-<repo>"
  # attribute_condition                = null
  attribute_mapping = {
    "google.subject": "assertion.sub",
    "attribute.actor": "assertion.actor",
    "attribute.aud": "assertion.aud"#,
    #"attribute.repository": "assertion.repository"
  }

  oidc {
    allowed_audiences = []
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "wif-sa" {
  for_each = local.repositories
  service_account_id = "projects/${var.project}/serviceAccounts/gha-cd-${each.value[1]}@${var.project}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  #member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.repository/${each.value[0]}/${each.value[1]}"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/*"
}
