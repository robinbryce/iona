# resource "google_redis_instance" "memcache" {
#   project            = "${local.gcp_project_id}"
#   region             = "${local.gcp_project_region}"
#   name               = "memcache"
#   memory_size_gb     = 1
#   connect_mode       = "PRIVATE_SERVICE_ACCESS"
#   authorized_network = local.vpc_network
# }
# 
# locals {
#   redis_memcache_endpoint = "${google_redis_instance.memcache.host}:${google_redis_instance.memcache.port}"
# }
