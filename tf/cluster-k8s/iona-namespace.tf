resource "kubernetes_namespace_v1" "cluster" {
  metadata {
    name = "${local.gcp_project_name}"
    labels = {
      name = "${local.gcp_project_name}"
    }
  }
}
output "cluster_namespace" { value = kubernetes_namespace_v1.cluster.metadata[0].name }
