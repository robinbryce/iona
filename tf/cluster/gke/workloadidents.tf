resource "google_service_account" "workloads" {
  for_each = {
    kubeip = ["kube-system", "kubeip-sa"]
  }
  account_id   = each.value[1]
  display_name = substr("Workload Identity ${local.gcp_project_sa_fqn}[${each.value[0]}/${each.value[1]}]", 0, 100)
  project      = var.project
}

resource "google_service_account_iam_member" "workloads" {
  for_each = {
    kubeip = ["kube-system", "kubeip-sa"]
  }

  service_account_id = google_service_account.workloads[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "${local.gcp_project_sa_fqn}[${each.value[0]}/${each.value[1]}]"
}
