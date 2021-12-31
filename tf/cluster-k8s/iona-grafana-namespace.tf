resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}
output "monitoring_namespace" { value = kubernetes_namespace_v1.monitoring.metadata[0].name }

locals {
  monitoring_namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
}

