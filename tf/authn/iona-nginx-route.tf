resource "kubernetes_manifest" "iona-nginx-route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind = "IngressRoute"
    metadata = {
      name = "ingressroutetls"
      namespace = "${local.cluster_namespace}"
    }
    spec = {
      entrypoints = [ "websecure" ]
      routes = [{
        match = "Host(`${local.gcp_project_name}.thaumagen.io`) && PathPrefix(`/static`)"
        kind = "Rule"
        services = [{ name = "nginx-web", port = "80" }]
      }]
      tls = {
        cert_resolver = "letsencrypt"
        domains = [{
          main = "*.thaumagen.io",
          sans = "*.thaumagen.io"
        }]
      }
    }
  }
}
