resource "kubernetes_manifest" "ingressroutes" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "IngressRoute"
        plural = "ingressroutes"
        singular = "ingressroute"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}
