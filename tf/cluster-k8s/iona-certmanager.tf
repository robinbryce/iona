resource "helm_release" "certmanager" {
  name        = "certmanager"
  namespace   = "iona"
  chart       = "cert-manager"
  repository  = "https://charts.jetstack.io"
  version     = "v1.6.1"
  set {
    name  = "installCRDs"
    value = "true"
  }
}
