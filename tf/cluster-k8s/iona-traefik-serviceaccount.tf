resource "kubernetes_service_account_v1" "traefik" {
  metadata {
    name = "dns01solver-sa"
    namespace = "${local.gcp_project_name}"
    annotations = {
      "iam.gke.io/gcp-service-account" = "dns01solver-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
    }
  }
}
