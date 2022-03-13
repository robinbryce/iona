module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.project
  pool_id     = "github-oidc"
  provider_id = "github-provider"
  provider_description = "Workload Identity Pool Provider for GitHub Actions based CD. A service account exists for each enabled repository, named after that repostiory gha-cd-<repo>"
  sa_mapping = {
    "gha-cd-iona-app" = {
      sa_name   = "projects/${var.project}/serviceAccounts/gha-cd-iona-app@${var.project}.iam.gserviceaccount.com"
      attribute = "attribute.repository/robinbryce/iona-app"
    }
  }
}
