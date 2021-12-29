resource "kubernetes_config_map_v1" "iona-static-pages" {
  metadata {
    name = "iona-static-pages"
    namespace = "${local.gcp_project_name}"
  }
  data = {
    "index.html" = "${file("${path.module}/iona-static-pages/index.html")}"
    "terms.html" = "${file("${path.module}/iona-static-pages/terms.html")}"
    "style.css" = "${file("${path.module}/iona-static-pages/style.css")}"
  }
  binary_data = {
    "favicon.ico" = "${filebase64("${path.module}/iona-static-pages/favicon.ico")}"
    "favicon-16x16.png" = "${filebase64("${path.module}/iona-static-pages/favicon-16x16.png")}"
    "favicon-32x32.png" = "${filebase64("${path.module}/iona-static-pages/favicon-32x32.png")}"
  }
}
