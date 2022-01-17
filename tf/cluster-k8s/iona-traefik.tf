resource "helm_release" "traefik" {
  name = "traefik"
  namespace = "${local.gcp_project_name}"
  chart = "traefik"
  repository = "https://helm.traefik.io/traefik"

  values = [
    "${file("iona-traefik-values.yaml")}"
  ]
  # requires redis
  #set {
  #   name = "additionalArguments"
  #   value = "{--api.insecure=true,--providers.file.directory=/etc/traefik/dynamic/default-routes,--providers.redis=true,--providers.redis.endpoints=${local.redis_memcache_endpoint},--certificatesresolvers.letsencrypt.acme.dnschallenge=true,--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=gcloud,--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory,--certificatesresolvers.letsencrypt.acme.email=${var.traefik_acme_email},--certificatesresolvers.letsencrypt.acme.storage=traefik/acme/account}"
  #}
  set {
     name = "additionalArguments"
     value = "{--api.insecure=true,--providers.file.directory=/etc/traefik/dynamic/default-routes,--certificatesresolvers.letsencrypt.acme.dnschallenge=true,--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=gcloud,--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory,--certificatesresolvers.letsencrypt.acme.email=${var.traefik_acme_email},--certificatesresolvers.letsencrypt.acme.storage=traefik/acme/account}"
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
    ACME_EMAIL = "${var.traefik_acme_email}"
    REDIS_ENDPOINT = "${local.redis_memcache_endpoint}"
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
