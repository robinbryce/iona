resource "kubernetes_manifest" "ingressroutes" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "IngressRoute"
        plural = "ingressroutes"
        singular = "ingressroute"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "middlewares" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "middlewares.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "Middleware"
        plural = "middlewares"
        singular = "middleware"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "ingressroutetcps" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutetcps.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "IngressRouteTCP"
        plural = "ingressroutetcps"
        singular = "ingressroutetcp"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "ingressrouteudps" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressrouteudps.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "IngressRouteUDP"
        plural = "ingressrouteudps"
        singular = "ingressrouteudp"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}

# resource "kubernetes_manifest" "serverstransports" {
#   manifest = {
#     apiVersion = "apiextensions.k8s.io/v1beta1"
#     kind = "CustomResourceDefinition"
#     metadata = {
#       name = "serverstransports.traefik.containo.us"
#     }
#     spec = {
#       group = "traefik.containo.us"
#       scope = "Namespaced"
#       names = {
#         kind = "ServersTransport"
#         plural = "serverstransports"
#         singular = "serverstransport"
#       }
# 
#       versions = [{
#         name    = "v1alpha1"
#         served  = true
#         storage = true
#         schema = {
#           openAPIV3Schema = {
#             type = "object"
#             properties = {
#               spec = {
#                 type = "object"
#                 "x-kubernetes-preserve-unknown-fields" = true
#               }
#               data = {
#                 type = "string"
#               }
#               refs = {
#                 type = "number"
#               }
#             }
#           }
#         }
#       }]
#     }
#   }
# }

resource "kubernetes_manifest" "tlsoptions" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "tlsoptions.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "TLSOption"
        plural = "tlsoptions"
        singular = "tlsoption"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "tlsstores" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "tlsstores.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "TLSStore"
        plural = "tlsstores"
        singular = "tlsstore"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "traefikservices" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "traefikservices.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      scope = "Namespaced"
      names = {
        kind = "TraefikService"
        plural = "traefikservices"
        singular = "traefikservice"
      }

      versions = [{
        name    = "v1alpha1"
        served  = true
        storage = true
        schema = {
          openAPIV3Schema = {
            type = "object"
            properties = {
              spec = {
                type = "object"
                "x-kubernetes-preserve-unknown-fields" = true
              }
              data = {
                type = "string"
              }
              refs = {
                type = "number"
              }
            }
          }
        }
      }]
    }
  }
}
