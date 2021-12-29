resource "kubernetes_service_v1" "iona-nginx" {
  metadata {
    name = "nginx"
    namespace = "${local.cluster_namespace}"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/name" = "nginx"
      "app.kubernetes.io/part-of" = "iona-authn"
    }
    port {
      name = "tcp-80"
      port = "80"
      target_port = "80"
    }
    port {
      name = "tcp-443"
      port = "443"
      target_port = "443"
    }
  }
}
