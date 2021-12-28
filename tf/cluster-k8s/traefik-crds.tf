resource "kubernetes_manifest" "ingressroutes" {
  manifest = {
    apiVersion = "v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      version = "v1alpha1"
      scope = "Namespaced"
      names = {
        kind = "IngressRoute"
        plural = "ingressroutes"
        singular = "ingressroute"
      }
    }
  }
}
