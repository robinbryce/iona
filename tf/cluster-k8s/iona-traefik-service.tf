resource "kubernetes_service_v1" "traefik" {
  metadata {
    name = "traefik-web"
  }
  spec {
    clusterIP = "None"
    selector {
      "app.kubernetes.io/name" = "traefik-web"
    }
    port {
      name = "web"
      port = "80"
      targetPort = "80"
    }
    port {
      name = "websecure"
      port = "443"
      targetPort = "443"
    }
    port {
      name = "admin"
      port = "8080"
      targetPort = "8080"
    }
  }
}
