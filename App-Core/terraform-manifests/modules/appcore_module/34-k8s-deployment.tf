# https://github.com/kubernetes/examples/tree/master/staging/volumes/azure_file
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_v1
# https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/_examples/job/main.tf
# https://learn.microsoft.com/en-us/azure/aks/concepts-storage
# https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision

# resource "kubernetes_deployment" "test" {
#   metadata {
#     name      = "nginx"
#     namespace = kubernetes_namespace.Enterprise.metadata.0.name
#   }
#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         app = "MyTestApp"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = "MyTestApp"
#         }
#       }
#       spec {
#         container {
#           image = "nginx"
#           name  = "nginx-container"
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
#   depends_on = [
#     azurerm_kubernetes_cluster.aks_cluster,
#     kubernetes_namespace.Enterprise,
#     azurerm_kubernetes_cluster_node_pool.machinelearning_jobs,
#   ]
# }
# resource "kubernetes_service" "test" {
#   metadata {
#     name      = "nginx"
#     namespace = kubernetes_namespace.Enterprise.metadata.0.name
#   }
#   spec {
#     selector = {
#       app = kubernetes_deployment.test.spec.0.template.0.metadata.0.labels.app
#     }
#     type = "NodePort"
#     port {
#       node_port   = 30201
#       port        = 80
#       target_port = 80
#     }
#   }
#   depends_on = [
#     azurerm_kubernetes_cluster.aks_cluster,
#     kubernetes_namespace.Enterprise,
#     azurerm_kubernetes_cluster_node_pool.machinelearning_jobs,
#   ]
# }

##########################################################
# Validation of mounted volume whithin the container:
###########################################################
# kubectl config set-context --current --namespace=Enterprise
# kubectl exec --stdin --tty terraform-example-client-anon -- /bin/bash
#
# root@terraform-example-client-anon:/# mount | grep mnt
//stappcoreclient-anon.file.core.windows.net/fs-appcore-client-anon-client-anon on /mnt type cifs 
# (rw,relatime,vers=3.1.1,cache=strict,username=stappcoreclient-anon,uid=0,noforceuid,gid=0,noforcegid,addr=127.0.0.1,file_mode=0777,
# dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30)