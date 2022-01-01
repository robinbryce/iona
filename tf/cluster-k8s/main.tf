variable "cluster_workspace" {
  type = string
  default = "cluster"
}
output "cluster_workspace" { value = var.cluster_workspace }

variable "cluster_name" {
    type = string
    default = "kluster"
}
output "cluster_name" { value = var.cluster_name }

variable "grafana_admin_password" {
  type = string
}

locals {
  # All remote state references are via variables with short cuts in the
  # locals.
  gcp_project_id = data.terraform_remote_state.cluster.outputs.gcp_project_id
  gcp_project_name = data.terraform_remote_state.cluster.outputs.gcp_project_name
  gcp_project_region = data.terraform_remote_state.cluster.outputs.gcp_project_region
  gcp_project_zone = data.terraform_remote_state.cluster.outputs.gcp_project_zone
  static_ingress = data.terraform_remote_state.cluster.outputs.static_ingress
  # this is the workload identity base for the cluster. All workload identities
  # are constructed from this - thats how they work.
  workloadid_fqdn = "serviceAccount:${data.terraform_remote_state.cluster.outputs.gcp_project_id}.svc.id.goog"
}

data "terraform_remote_state" "cluster" {
  backend = "remote"
  config = {
    organization = "robinbryce"
    workspaces = {
      # name = "iona-1"
      name = var.cluster_workspace
    }
  }
}

data "google_client_config" "provider" {}
data "google_container_cluster" "project" {
  name = var.cluster_name
  project = data.terraform_remote_state.cluster.outputs.gcp_project_id
  location = data.terraform_remote_state.cluster.outputs.gcp_project_zone
}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.project.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.project.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host = "https://${data.google_container_cluster.project.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.project.master_auth[0].cluster_ca_certificate,
    )
  }
}
