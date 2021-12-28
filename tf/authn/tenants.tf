
#-----------------------------------------------------------------------------
# admin tenant - only users in this tenant are permitted to administer the
# system
#-----------------------------------------------------------------------------
variable "admin_tenant" {
  type = string
}
output "admin_tenant" { value = var.admin_tenant }

variable "admin_tenant_client_id" {
  type = string
}
output "admin_tenant_client_id" { value = var.admin_tenant_client_id }

variable "admin_tenant_client_secret" {
  type = string
}

resource "google_identity_platform_tenant" "admin_tenant" {
  project = local.gcp_project_id
  display_name = "${var.admin_tenant}"
  allow_password_signup = true
}

resource "google_identity_platform_tenant_default_supported_idp_config" "idp_config" {
  project = local.gcp_project_id
  enabled       = true
  tenant        = google_identity_platform_tenant.admin_tenant.name
  idp_id        = "google.com"
  client_id     = "${var.admin_tenant_client_id}"
  client_secret = "${var.admin_tenant_client_secret}"
}

#-----------------------------------------------------------------------------
# public tenant - all users without a specific tenant
#-----------------------------------------------------------------------------
variable "public_tenant" {
  type = string
}
output "public_tenant" { value = var.public_tenant }

variable "public_tenant_client_id" {
  type = string
}
output "public_tenant_client_id" { value = var.public_tenant_client_id }

variable "public_tenant_client_secret" {
  type = string
}

resource "google_identity_platform_tenant" "public_tenant" {
  project = local.gcp_project_id
  display_name = "${var.public_tenant}"
  allow_password_signup = true
}
