# -----------------------------------------------------------------------------
# workload identity & iam for the dns01 solver
# -----------------------------------------------------------------------------
resource "google_service_account" "dns" {
  for_each = {
    dns01solver = ["${local.gcp_project_name}", "dns01solver-sa"]
  }
  account_id   = each.value[1]
  display_name = substr("Workload Identity ${local.workloadid_fqdn}[${each.value[0]}/${each.value[1]}]", 0, 100)
  project      = local.gcp_project_id
}

resource "google_service_account_iam_member" "dns" {
  for_each = {
    dns01solver = ["${local.gcp_project_name}", "dns01solver-sa"]
  }

  service_account_id = google_service_account.dns[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "${local.workloadid_fqdn}[${each.value[0]}/${each.value[1]}]"
}

# -----------------------------------------------------------------------------
# dns01 challenge role
# -----------------------------------------------------------------------------
resource "google_project_iam_custom_role" "dns01solver" {
  role_id = "dns01solver"
  title   = "DNS01 Solver Role"

  project    = local.gcp_project_id

  permissions = [
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.update",
    # removing delete doesn't fail the challenge but leaves the TXT record
    # hanging around - which can be useful for debugging
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.list",
    "dns.changes.create",
    "dns.changes.get",
    "dns.changes.list",
    "dns.managedZones.list"
  ]
}

# Add the DNS01 Solver Role to the dns01solver workload identity
resource "google_project_iam_member" "dns01solver" {

  depends_on = [google_project_iam_custom_role.dns01solver]
  project = local.gcp_project_id
  role = "projects/${local.gcp_project_id}/roles/dns01solver"
  member = "serviceAccount:${google_service_account.dns["dns01solver"].email}"
}
