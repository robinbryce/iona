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
  set {
     name = "additionalArguments"
     value = "{--api.insecure=true,--providers.file.directory=/etc/traefik/dynamic/default-routes,--providers.redis=true,--providers.redis.endpoints=${local.redis_memcache_endpoint},--certificatesresolvers.letsencrypt.acme.dnschallenge=true,--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=gcloud,--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory,--certificatesresolvers.letsencrypt.acme.email=${var.traefik_acme_email},--certificatesresolvers.letsencrypt.acme.storage=/data/letsencrypt/acme-staging.json}"
  }
  # {--api.insecure=true,
  # --providers.file.directory=/etc/traefik/dynamic/default-routes,
  # --providers.redis=true,
  # --providers.redis.endpoints=${local.redis_memcache_endpoint},
  # --certificatesresolvers.letsencrypt.acme.dnschallenge=true,
  # --certificatesresolvers.letsencrypt.acme.dnschallenge.provider=gcloud,
  # --certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory,
  # --certificatesresolvers.letsencrypt.acme.email=${var.traefik_acme_email},
  # --certificatesresolvers.letsencrypt.acme.storage=/data/letsencrypt/acme-staging.json}
  #- --entrypoints.web.address=:80
  #- --entrypoints.websecure.address=:443
  #- --entrypoints.ping.address=:10254
  # - --ping.entrypoint=ping
  # - --providers.redis.tls.ca=${REDIS_SERVER_CA}
  # - --providers.redis.tls.key=${REDIS_CLIENT_KEY}
  # - --providers.redis.tls.cert=${REDIS_CLIENT_CERT}
  #  - "--providers.kubernetesingress.ingressclass=traefik-internal"
  #  - "--log.level=DEBUG"

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
