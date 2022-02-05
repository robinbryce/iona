resource "kubernetes_service_account_v1" "traefik-sa" {
  metadata {
    name = "traefik-sa"
    namespace = "${local.gcp_project_name}"
    # annotations = {
    #   "iam.gke.io/gcp-service-account" = "traefik-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
    # }
  }
}
