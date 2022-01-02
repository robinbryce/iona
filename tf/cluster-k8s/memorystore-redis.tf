resource "google_redis_instance" "memcache" {
  project        = "${local.gcp_project_id}"
  region         = "${local.gcp_project_region}"
  name           = "memcache"
  memory_size_gb = 1
}

locals {
  redis_memcache_endpoint = "${google_redis_instance.memcache.host}${google_redis_instance.memcache.port}"
}
