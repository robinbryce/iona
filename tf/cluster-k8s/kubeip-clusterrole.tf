# ----------------------------------------------------------------------------
# role
# ----------------------------------------------------------------------------
resource "kubernetes_cluster_role" "kubeip" {
  metadata {
    name = "kubeip-sa"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

# ----------------------------------------------------------------------------
# role binding
# ----------------------------------------------------------------------------
resource "kubernetes_cluster_role_binding" "kubeip" {
  metadata {
    name = "kubeip-sa"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubeip-sa"
    # be explicit, because the GCP SA binding only works for the declared ns
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kubeip-sa"
  }
}
