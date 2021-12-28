resource "kubernetes_cluster_role" "traefik" {
  metadata {
    name = "traefik"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups = ["traefik.containo.us"]
    resources  = [
      "middlewares"
      "ingressroutes"
      "traefikservices"
      "ingressroutetcps"
      "ingressrouteudps"
      "tlsoptions"
      "tlsstores"
    ]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "traefik" {
  metadata {
    name = "traefik"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "dns01solver-sa"
    # be explicit, because the GCP SA binding only works for the declared ns
    namespace = "${local.gcp_project_name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik"
  }
}
