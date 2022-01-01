resource "helm_release" "grafana" {
  name = "grafana"
  chart = "grafana"
  version = "6.20.3"
  repository = "https://grafana.github.io/helm-charts"

  values = [
    "${file("monitoring-grafana-values.yaml")}"
  ]
  set {
    name = "rbac.create"
    value = "false"
  }
  set {
    name = "rbac.useExistingRole"
    value = "${kubernetes_service_account_v1.grafana.name}"
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }
  set {
    name = "serviceAccount.name"
    value = "${kubernetes_service_account_v1.grafana.name}"
  }

  # nodeSelector set in values.yaml (read above)
}

resource "kubernetes_service_account_v1" "grafana" {
  metadata {
    name = "grafana-sa"
    namespace = "${local.monitoring_namespace}"
    annotations = {
      "iam.gke.io/gcp-service-account" = "grafana-sa@${local.gcp_project_id}.iam.gserviceaccount.com"
    }
  }
}

resource "google_project_iam_member" "iam_member_grafana" {
  project = local.gcp_project_id
  # https://grafana.com/docs/grafana/latest/datasources/google-cloud-monitoring/
  # role = "projects/${local.gcp_project_id}/roles/monitoring.viewer" #  Monitoring Viewer
  role    = "roles/monitoring.viewer" #  Monitoring Viewer
  member = "serviceAccount:${google_service_account.grafana.email}"
}

resource "kubernetes_cluster_role_binding" "grafana" {
  metadata {
    name = "grafana-sa"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "grafana-sa"
    # be explicit, because the GCP SA binding only works for the declared ns
    namespace = "${local.monitoring_namespace}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "grafana-sa"
  }
}

resource "google_service_account" "grafana" {
  account_id   = "grafana-sa"
  display_name = substr(
    "Workload Identity ${local.workloadid_fqdn}[${local.monitoring_namespace}/grafana-sa]", 0, 100)
  project      = local.gcp_project_id
}

resource "google_service_account_iam_member" "grafana" {
  service_account_id = google_service_account.grafana.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "${local.workloadid_fqdn}[${local.monitoring_namespace}/grafana-sa]"
}
