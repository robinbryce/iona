resource "helm_release" "traefik" {
  name = "traefik"
  namespace = "${local.gcp_project_name}"
  chart = "traefik"
  repository = "https://helm.traefik.io/traefik"

  values = [
    "${file("iona-traefik-values.yaml")}"
  ]
  # set {
  #   name = "additionalArguments"
  #   value = "{--certificatesresolvers.letsencrypt.acme.email=${var.traefik_acme_email}}"
  # }
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
    ACME_EMAIL: "robin.bryce@thaumagen.com"
    REDIS_ENDPOINT: "${local.redis_memcache_endpoint}"
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
