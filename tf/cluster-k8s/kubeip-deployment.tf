#  We need to get RBAC permissions first with
#  kubectl create clusterrolebinding cluster-admin-binding \
#    --clusterrole cluster-admin --user `gcloud config list --format 'value(core.account)'`

resource "kubernetes_deployment_v1" "kubeip" {
  metadata {
    name = "kubeip"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kubeip"
      }
    }

    template {
      metadata {
        labels = {
          app = "kubeip"
        }
      }

      spec {
        priority_class_name = "system-cluster-critical"
        node_selector = {
          "cloud.google.com/gke-nodepool" = "work-pool"
        }
        restart_policy = "Always"
        service_account_name = "kubeip-sa"
        automount_service_account_token = true

        container {
          image = "doitintl/kubeip:1.0"
          name  = "kubeip"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "50Mi"
            }
          }
          env {
            name = "KUBEIP_LABELKEY"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_LABELKEY"
                name = "kubeip-config"
              }
            }
          }
          env {
            name = "KUBEIP_LABELVALUE"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_LABELVALUE"
                name = "kubeip-config"
              }
            }
          }
          env {
            name = "KUBEIP_NODEPOOL"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_NODEPOOL"
                name = "kubeip-config"
              }
            }
          }
          env {
            name = "KUBEIP_FORCEASSIGNMENT"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_FORCEASSIGNMENT"
                name = "kubeip-config"
              }
            }
          }
          env {
            name = "KUBEIP_ADDITIONALNODEPOOLS"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_ADDITIONALNODEPOOLS"
                name = "kubeip-config"
              }
            }
          }
          env {
            name = "KUBEIP_TICKER"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_TICKER"
                name = "kubeip-config"
              }
            }
          }
          env {
            name = "KUBEIP_ALLNODEPOOLS"
            value_from {
              config_map_key_ref {
                key = "KUBEIP_ALLNODEPOOLS"
                name = "kubeip-config"
              }
            }
          }
        }
      }
    }
  }
}
