variable "ingress_domain" {
  type = string
}
output "ingress_domain" { value = var.ingress_domain }

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

resource "google_dns_record_set" "subdomain" {
  for_each = toset( ["admin", "grafana"] )
  project = local.gcp_project_id
  name = "${each.key}.${local.gcp_project_name}.${google_dns_managed_zone.primary.dns_name}"
  managed_zone = google_dns_managed_zone.primary.name
  type = "CNAME"
  ttl = 3600

  rrdatas = ["${local.gcp_project_name}.${google_dns_managed_zone.primary.dns_name}"]
}
