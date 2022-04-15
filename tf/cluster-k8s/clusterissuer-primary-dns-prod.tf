resource "kubernetes_manifest" "clusterissuer_letsencrypt_prod_primary_dns" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod-primary-dns"
    }
    "spec" = {
      "acme" = {
        "email" = "${var.traefik_acme_email}" # XXX: TODO rename
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod-primary-dns-issuer-key"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudDNS" = {
                "hostedZoneName" = "primary-dns"
                "project" = "${local.gcp_project_id}"
              }
            }
          }
        ]
      }
    }
  }
}
