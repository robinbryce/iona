# static pages for authn
resource "kubernetes_config_map_v1" "iona-authn-pages" {
  metadata {
    name = "iona-authn-pages"
    namespace = "${local.cluster_namespace}"
  }
  data = {
    "index.html" = "${file("${path.module}/iona-authn-pages/index.html")}"
  }
  binary_data = {
    "favicon.ico" = "${filebase64("${path.module}/iona-static-pages/favicon.ico")}"
    "favicon-16x16.png" = "${filebase64("${path.module}/iona-static-pages/favicon-16x16.png")}"
    "favicon-32x32.png" = "${filebase64("${path.module}/iona-static-pages/favicon-32x32.png")}"
  }
}
