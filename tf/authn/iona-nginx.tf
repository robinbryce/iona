resource "kubernetes_deployment_v1" "iona-nginx" {
  metadata {
    name = "nginx"
    namespace = "${local.cluster_namespace}"
    labels = {
      "app.kubernetes.io/name" = "nginx"
      "app.kubernetes.io/part-of" = "iona-authn"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "nginx"
        "app.kubernetes.io/part-of" = "iona-authn"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "nginx"
          "app.kubernetes.io/part-of" = "iona-authn"
        }
      }
      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = "work-pool"
        }
        volume {
          name = "iona-nginx-conf"
          config_map {
            name = "iona-nginx"
          }
        }
        volume {
          name = "iona-static-pages"
          config_map {
            name = "iona-static-pages"
          }
        }

        container {
          image = "nginx:1.21"
          name = "nginx"
          volume_mount {
              mount_path = "/etc/nginx"
              name = "iona-nginx-conf"
          }
          volume_mount {
              mount_path = "/etc/nginx/html/static"
              name = "iona-static-pages"
          }
          port {
            container_port = 80
            name = "http"
          }
          port {
            container_port = 443
            name = "https"
          }
          liveness_probe {
            failure_threshold = 3
            http_get {
              path = "/health"
              port = 80
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 1
            timeout_seconds = 1
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path = "/health"
              port = 80
              scheme = "HTTP"
            }
            period_seconds = 10
            success_threshold = 1
            timeout_seconds = 1
          }
        }
      }
    }
  }
}
