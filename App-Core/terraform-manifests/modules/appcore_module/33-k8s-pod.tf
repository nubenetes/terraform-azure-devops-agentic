# https://github.com/kubernetes/examples/tree/master/staging/volumes/azure_file
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_v1
# https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/job/main.tf
# https://learn.microsoft.com/en-us/azure/aks/concepts-storage
# https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision

# resource "kubernetes_pod_v1" "my_client_test" {
#   for_each              = toset(var.client_names)
#   metadata {
#     name = "terraform-example-${each.value}"
#     namespace = "Enterprise"
#   }

#   spec {
#       node_selector = {"nodepool-type":"user"}
#       affinity {
#       node_affinity {
#         required_during_scheduling_ignored_during_execution {
#           node_selector_term {
#             match_expressions {
#               key      = "app"
#               operator = "In"
#               values   = ["appcore"]
#             }
#           }
#         }

#         preferred_during_scheduling_ignored_during_execution {
#           weight = 1
#           preference {
#             match_expressions {
#               key      = "app"
#               operator = "In"
#               values   = ["appcore"]
#             }
#           }
#         }
#       }
#     }

#     # resources is a computed attribute and thus if it is not configured in terraform code, the value will be computed from the returned Kubernetes object. 
#     # That causes a situation when removing resources from terraform code does not update the Kubernetes object. In order to delete resources from the Kubernetes object, configure an empty attribute in your code.
#     container {
#       image = "nginx:1.21.6"
#       name  = "example"

#       env {
#         name  = "environment"
#         value = "test"
#       }

#       port {
#         container_port = 80
#       }
#       resources {
#         requests = {
#           memory = "64Mi"
#           cpu = "250m"
#           }
#         limits   = {
#           memory = "128Mi"
#           cpu = "500m"
#           }          
#       }
#       liveness_probe {
#         http_get {
#           path = "/"
#           port = 80

#           http_header {
#             name  = "X-Custom-Header"
#             value = "Awesome"
#           }
#         }

#         initial_delay_seconds = 3
#         period_seconds        = 3
#       }
#       volume_mount {
#         mount_path = "/mnt"
#         name = "${each.value}"
#       }
#     }

#     volume {
#         name = each.value
#         persistent_volume_claim {
#           claim_name = "${kubernetes_persistent_volume_claim_v1.my_client[each.key].metadata.0.name}"
#         } 
#     }

#     dns_config {
#       nameservers = ["127.0.0.1", "127.0.0.1", "127.0.0.1"]
#       searches    = ["example-${each.value}.com"]

#       option {
#         name  = "ndots"
#         value = 1
#       }

#       option {
#         name = "use-vc"
#       }
#     }

#     dns_policy = "None"
#   }
# }