resource "kubernetes_manifest" "clusterissuer_letsencrypt_staging_primary_dns" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-staging-primary-dns"
    }
    "spec" = {
      "acme" = {
        "email" = "${local.traefik_acme_email}" # XXX: TODO rename
        "privateKeySecretRef" = {
          "name" = "letsencrypt-staging-primary-dns-issuer-key"
        }
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudDNS" = {
                "hostedZoneName" = "primary-dns"
                "project" = "${local.gcp_project_name}"
              }
            }
          }
        ]
      }
    }
  }
}
