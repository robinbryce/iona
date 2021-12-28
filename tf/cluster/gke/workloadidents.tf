locals {
  # this is the workload identity base for the cluster. All workload identities
  # are constructed from this - thats how they work.
  workloadid_fqdn = "serviceAccount:${var.project}.svc.id.goog"
}

resource "google_service_account" "workloads" {
  for_each = {
    kubeip = ["kube-system", "kubeip-sa"]
  }
  account_id   = each.value[1]
  display_name = substr("Workload Identity ${local.workloadid_fqdn}[${each.value[0]}/${each.value[1]}]", 0, 100)
  project      = var.project
}

resource "google_service_account_iam_member" "workloads" {
  for_each = {
    kubeip = ["kube-system", "kubeip-sa"]
  }

  service_account_id = google_service_account.workloads[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "${local.workloadid_fqdn}[${each.value[0]}/${each.value[1]}]"
}
