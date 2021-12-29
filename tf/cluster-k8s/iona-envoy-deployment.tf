resource "kubernetes_deployment_v1" "envoy-lb" {
  metadata {
    name = "envoy-lb"
    namespace = "${local.gcp_project_name}"
    labels = {
      app = "envoy-lb"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "envoy-lb"
      }
    }

    strategy {
      # The taints don't allow > 1 pod to run, so rolling update can't work.
      type = "Recreate"
    }
    template {
      metadata {
        name = "envoy-lb"
        labels = {
          app = "envoy-lb"
        }
      }
      spec {
        host_network = true
        dns_policy = "ClusterFirstWithHostNet"
        node_selector = {
          "cloud.google.com/gke-nodepool" = "ingress-pool"
        }
        toleration {
          effect = "NoExecute"
          key = "ingress-pool"
          operator = "Equal"
          value = true
        }
        volume {
          name = "envoy-conf"
          config_map {
            name = "envoy-conf"
          }
        }
        container {
          image = "envoyproxy/envoy:v1.20.1"
          name = "envoy-lb"

          volume_mount {
            mount_path = "/etc/envoy"
            name = "envoy-conf"
          }
          port {
            container_port = 8080
            protocol = "TCP"
            name = "web"
          }
          port {
            container_port = 443
            protocol = "TCP"
            name = "websecure"
          }
          # kubernetes/terraform provider is having trouble with this. it might
          # not be specific to terraforms kubernetes provider - we are listening on the
          # host network (the single vm in the ingress-pool)
          # port {
          #   container_port = 9090
          #   protocol = "TCP"
          #   name = "admin"
          # }
          args = [
            "--config-path /etc/envoy/envoy.yaml",
            "--component-log-level upstream:debug,connection:trace"
          ]
          command = [ "/usr/local/bin/envoy" ]
          liveness_probe {
            failure_threshold = 3
            tcp_socket {
              port = 443
            }
            initial_delay_seconds = 10
            period_seconds = 10
            success_threshold = 1
            timeout_seconds = 1
          }
          readiness_probe {
            failure_threshold = 3
            tcp_socket {
              port = 443
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
