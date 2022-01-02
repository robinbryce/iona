resource "google_redis_instance" "memcache" {
  project        = "${local.gcp_project_id}"
  zone           = "${local.gcp_project_zone}"
  region         = "${local.gcp_project_region}"
  name           = "memcache"
  memory_size_gb = 1
}

locals {
  redis_memcache_endpoint = "${google_redis_instance.memcache.host}${google_redis_instance.memcache.port}"
  redis_memcache_cert = "${google_redis_instance.memcache.server_ca_certs[0].cert}"
}
