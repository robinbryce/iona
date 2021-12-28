resource "kubernetes_config_map" "kubeip-config" {
  metadata {
    labels = {
      app = "kubeip"
    }
    name = "kubeip-config"
  }

  data = {
    KUBEIP_LABELKEY = "kubeip"
    KUBEIP_LABELVALUE = "static-ingress"
    KUBEIP_SELF_NODEPOOL = "work-pool"
    KUBEIP_NODEPOOL = "ingress-pool"
    KUBEIP_FORCEASSIGNMENT = "true"
    KUBEIP_ADDITIONALNODEPOOLS = ""
    KUBEIP_TICKER = "5"
    KUBEIP_ALLNODEPOOLS = "false"
  }
}
