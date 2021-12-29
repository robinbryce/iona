resource "kubernetes_deployment_v1" "traefik" {
  metadata {
    name = "traefik-web"
    namespace = "${local.gcp_project_name}"
    labels = {
      "app.kubernetes.io/name" = "traefik-web"
      "app.kubernetes.io/part-of" = "traefik-web"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "traefik-web"
        "app.kubernetes.io/part-of" = "traefik-web"
      }
    }
    strategy {
      # The taints don't allow > 1 pod to run, so rolling update can't work.
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "traefik-web"
          "app.kubernetes.io/part-of" = "traefik-web"
        }
      }
      spec {
        automount_service_account_token = true
        node_selector = {
          "cloud.google.com/gke-nodepool" = "ingress-pool"
        }
        service_account_name = "dns01solver-sa"
        toleration {
          effect = "NoExecute"
          key = "ingress-pool"
          operator = "Equal"
          value = "true"
        }
        volume {
          name = "acme-certs"
        }

        container {
          image = "traefik:2.5"
          name = "traefik"
          volume_mount {
              mount_path = "/var/run/acme"
              name = "acme-certs"
          }

          env {
            name = "ACME_EMAIL"
            value = "noreply@${local.gcp_project_name}.thaumagen.io"
          }
          port {
            container_port = 80
            name = "web"
          }
          port {
            container_port = 443
            name = "websecure"
          }
          port {
            container_port = 8080
            name = "admin"
          }


          args = [
            "-cx",
            <<-EOT
            set -e
            traefik \
              --api.insecure=true \
              --entrypoints.web.address=:80 \
              --entrypoints.websecure.address=:443 \
              --entrypoints.ping.address=:10254 \
              --ping.entrypoint=ping \
              --log.level=DEBUG \
              --providers.kubernetescrd \
              --certificatesresolvers.letsencrypt.acme.dnschallenge=true \
              --certificatesresolvers.letsencrypt.acme.dnschallenge.provider=gcloud \
              --certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory \
              --certificatesresolvers.letsencrypt.acme.email=$${ACME_EMAIL} \
              --certificatesresolvers.letsencrypt.acme.storage=/var/run/acme/acme-staging.json
            EOT
          ]
          command = [
            "sh",
          ]
          liveness_probe {
            failure_threshold = 3
            http_get {
              path = "/ping"
              port = 10254
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
              path = "/ping"
              port = 10254
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
