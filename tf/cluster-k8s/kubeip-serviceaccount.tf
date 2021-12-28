resource "kubernetes_service_account_v1" "kubeip-sa" {
  metadata {
    name = "kubeip-sa"
    namespace = "kube-system"
    annotations = {
      "iam.gke.io/gcp-service-account" = "kubeip-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
    }
  }
}
