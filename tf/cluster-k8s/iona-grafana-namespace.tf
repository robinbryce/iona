resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "${local.gcp_project_name}"
    labels = {
      name = "${local.gcp_project_name}"
    }
  }
}
output "monitoring_namespace" { value = kubernetes_namespace_v1.monitoring.metadata[0].name }

locals {
  monitoring_namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
}

