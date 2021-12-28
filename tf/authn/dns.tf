variable "ingress_domain" {
  type = string
}
output "ingress_domain" { value = var.ingress_domain }

# -----------------------------------------------------------------------------
# workload identity & iam for the dns01 solver
# -----------------------------------------------------------------------------
resource "google_service_account" "dns" {
  for_each = {
    dns01solver = ["traefik", "dns01solver-sa"]
  }
  account_id   = each.value[1]
  display_name = substr("Workload Identity ${local.workloadid_fqdn}[${each.value[0]}/${each.value[1]}]", 0, 100)
  project      = local.gcp_project_id
}

resource "google_service_account_iam_member" "dns" {
  for_each = {
    dns01solver = ["traefik", "dns01solver-sa"]
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

# -----------------------------------------------------------------------------
# dns zone and records
# -----------------------------------------------------------------------------

resource "google_dns_managed_zone" "primary" {
  project = local.gcp_project_id
  name = "primary-dns"
  dns_name = "${var.ingress_domain}."
  description = "dns zone"
}

resource "google_dns_record_set" "a" {
  project = local.gcp_project_id
  name = "${local.gcp_project_name}.${google_dns_managed_zone.primary.dns_name}"
  managed_zone = google_dns_managed_zone.primary.name
  type = "A"
  ttl = 300

  rrdatas = [local.static_ingress] # remote state from cluster
}

resource "google_dns_record_set" "cname" {
  project = local.gcp_project_id
  name = "admin.${local.gcp_project_name}.${google_dns_managed_zone.primary.dns_name}"
  managed_zone = google_dns_managed_zone.primary.name
  type = "CNAME"
  ttl = 300

  rrdatas = ["${local.gcp_project_id}.${google_dns_managed_zone.primary.dns_name}"]
}
