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

  # certmanager sa
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "${google_service_account.dns["dns01solver"].account_id}"
  }

  # certmanager-webhook sa
  set {
    name  = "webhook.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "webhook.serviceAccount.name"
    value = "${google_service_account.dns["dns01solver"].account_id}"
  }

  # certmanager-cainjector sa
  set {
    name  = "cainjector.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "cainjector.serviceAccount.name"
    value = "${google_service_account.dns["dns01solver"].account_id}"
  }

  # certmanager-startupapicheck sa
  set {
    name  = "startupapicheck.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "startupapicheck.serviceAccount.name"
    value = "${google_service_account.dns["dns01solver"].account_id}"
  }
}
