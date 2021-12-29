resource "kubernetes_config_map_v1" "iona-nginx" {
  metadata {
    name = "iona-nginx"
    namespace = "${local.cluster_namespace}"
  }
  data = {
    "nginx.conf" = "${file("${path.module}/iona-nginx.conf")}"
  }
}

