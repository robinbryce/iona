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

# hack around the fact that pools don't like to be re-created
#resource "google_iam_workload_identity_pool" "main" {
#  provider                  = google-beta
#  project                   = var.project
#  workload_identity_pool_id = "github-oidc"
#  display_name              = "Workload Identity Pool managed by Terraform"
#  description               = "Workload Identity Pool managed by Terraform"
#  disabled                  = false
#}

locals {
  wif_pool_id = "projects/iona-1/locations/global/workloadIdentityPools/github-oidc"
  wif_pool_numeric_id = "projects/871349271977/locations/global/workloadIdentityPools/github-oidc"
}

resource "google_iam_workload_identity_pool_provider" "main" {
  provider                           = google-beta
  project                            = var.project
  # hack around the fact that pools don't like to be re-created
  # workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_id          = local.wif_pool_id
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
  member             = "principalSet://iam.googleapis.com/${local.wif_pool_numeric_id}/attribute.repository/${each.value[0]}/${each.value[1]}"
  #member             = "principalSet://iam.googleapis.com/${local.wif_pool_numeric_id}/*"
}

### We need the service accounts to exist before creating thw workload identity
### pool resources which refere to them. This module should have been created at the top level so that it can depend on the
### cluster module. Its difficult to fix this because the pools can't be deleted
### by tf
#module "gh_oidc" {
#  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
#  project_id  = var.project
#  pool_id     = "github-oidc"
#  provider_id = "github-provider"
#  provider_description = "Workload Identity Pool Provider for GitHub Actions based CD. A service account exists for each enabled repository, named after that repostiory gha-cd-<repo>"
#  attribute_mapping = {
#    "google.subject": "assertion.sub",
#    "attribute.actor": "assertion.actor",
#    "attribute.aud": "assertion.aud"#,
#    #"attribute.repository": "assertion.repository"
#  }
#
#  sa_mapping = {
#
#    "gha-cd-iona-app" = {
#      sa_name   = "projects/${var.project}/serviceAccounts/gha-cd-iona-app@${var.project}.iam.gserviceaccount.com"
#      # attribute = "attribute.repository/robinbryce/iona-app"
#      attribute = "*"
#    }
#    "gha-cd-tokenator" = {
#      sa_name   = "projects/${var.project}/serviceAccounts/gha-cd-tokenator@${var.project}.iam.gserviceaccount.com"
#      # attribute = "attribute.repository/robinbryce/iona-app"
#      attribute = "*"
#    }
#  }
#  # depends_on = [ module.cluster ]
#}
