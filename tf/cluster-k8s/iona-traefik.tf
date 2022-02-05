resource "helm_release" "traefik" {
  name = "traefik"
  namespace = "${local.gcp_project_name}"
  chart = "traefik"
  repository = "https://helm.traefik.io/traefik"

  values = [
    "${file("iona-traefik-values.yaml")}"
  ]
  set {
     name = "additionalArguments"
     value = "{--api.insecure=true,--providers.file.directory=/etc/traefik/dynamic/default-routes}"
  }
}

resource "kubernetes_config_map_v1" "traefik-env" {
  metadata {
    labels = {
      app = "traefik"
    }
    name = "traefik-env"
    namespace = "${local.gcp_project_name}"
  }

  data = {
    # REDIS_ENDPOINT = "${local.redis_memcache_endpoint}"
  }
}

resource "kubernetes_config_map_v1" "traefik-default-routes" {
  metadata {
    name = "traefik-default-routes"
    namespace = "${local.gcp_project_name}"
  }
  data = {
    "traefik-default-routes.yaml" = "${file("${path.module}/iona-traefik-default-routes.yaml")}"
  }
}
