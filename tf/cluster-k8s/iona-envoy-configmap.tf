resource "kubernetes_config_map_v1" "envoy" {
  metadata {
    name = "envoy-conf"
  }
  data = {
    "envoy.yaml" = "${file("${path.module}/iona-envoy.yaml")}"
  }
}
