resource "kubernetes_service_v1" "traefik" {
  metadata {
    name = "traefik-web"
  }
  spec {
    cluster_ip = "None"
    selector = {
      "app.kubernetes.io/name" = "traefik-web"
    }
    port {
      name = "web"
      port = "80"
      target_port = "80"
    }
    port {
      name = "websecure"
      port = "443"
      target_port = "443"
    }
    port {
      name = "admin"
      port = "8080"
      target_port = "8080"
    }
  }
}
