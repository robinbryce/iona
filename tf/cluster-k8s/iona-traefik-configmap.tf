resource "kubernetes_config_map_v1" "traefik-dynamic-config" {
  metadata {
    name = "traefik-dynamic-config"
    namespace = "${local.gcp_project_name}"
  }
  data = {
    "iona-traefik-routes.yaml" = "${file("${path.module}/iona-traefik-routes.yaml")}"
  }
}
