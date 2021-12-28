variable "admin_tenant" {
  type = string
}
output "admin_tenant" { value = var.admin_tenant }


resource "google_identity_platform_tenant" "admin_tenant" {
  display_name = "${var.admin_tenant}"
  allow_password_signup = true
}

variable "public_tenant" {
  type = string
}
output "public_tenant" { value = var.public_tenant }

resource "google_identity_platform_tenant" "public_tenant" {
  display_name = "${var.public_tenant}"
  allow_password_signup = true
}
