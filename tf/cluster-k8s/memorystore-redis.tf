resource "google_redis_instance" "memcache" {
  name           = "memcache"
  memory_size_gb = 1
}
