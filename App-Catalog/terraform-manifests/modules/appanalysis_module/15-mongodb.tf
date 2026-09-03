##############################
# MONGODB PROJECT
##############################

resource "mongodbatlas_project" "project" {
  for_each = toset(var.client_names) # https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
  name     = "${var.Enterprise_product}-${each.value}-${local.instance_environment}"
  org_id   = var.mongodb_atlas_org_id
  #project_owner_id  = "cloud-admin@example.com"  # not valid since an email addr is not a valid ID
  # Optional) Unique 24-hexadecimal digit string that identifies the Atlas user account to be granted the Project Owner role on the specified project.
  # If you set this parameter, it overrides the default value of the oldest Organization Owner.
}


##############################
# MONGODB IP ACCESS LIST
##############################
resource "mongodbatlas_project_ip_access_list" "ip" {
  for_each   = toset(var.client_names)
  project_id = mongodbatlas_project.project[each.key].id
  cidr_block = var.mongodb_atlas_cidr_block
  comment    = "IP Address for accessing the cluster"
  depends_on = [
    mongodbatlas_project.project,
  ]
}

##############################
# MONGODB ATLAS CLUSTER
##############################

##############################
# MONGODB ATLAS ADVANCED CLUSTER (Modern September 2026 Specification)
##############################

resource "mongodbatlas_advanced_cluster" "cluster" {
  for_each     = toset(var.client_names)
  name         = "${var.Enterprise_product}-${each.value}-${var.environment}"
  project_id   = mongodbatlas_project.project[each.key].id
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      priority      = 7
      provider_name = var.mongodb_atlas_cloud_provider
      region_name   = var.mongodb_atlas_region
    }
  }

  advanced_configuration {
    oplog_size_mb = var.oplog_size_mb
  }

  backup_enabled = true

  tags {
    key   = "Client"
    value = each.value
  }

  tags {
    key   = "Environment"
    value = var.environment
  }

  tags {
    key   = "ManagedBy"
    value = "Terraform-Agentic"
  }

  provisioner "local-exec" {
    command = "chmod +x creation-time-provisioner-mongodb.sh; ./creation-time-provisioner-mongodb.sh ${self.connection_strings[0].standard_srv} modb-${var.Enterprise_product}-${each.value} ${var.mongodb_atlas_dbadmin} ${var.secret_mongodb_atlas_dbadmin_password}"
  }

  depends_on = [
    mongodbatlas_project.project,
    mongodbatlas_project_ip_access_list.ip,
    mongodbatlas_database_user.admin,
  ]
}


##########################################################################################################################
# MONGODB RESTORE
# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_backup_snapshot_restore_job
##########################################################################################################################

# resource "mongodbatlas_cloud_provider_snapshot" "test" {
#   for_each          = toset(var.client_names)
#   project_id        = mongodbatlas_advanced_cluster.cluster[each.key].project_id
#   cluster_name      = mongodbatlas_advanced_cluster.cluster[each.key].name
#   description       = "myDescription"
#   retention_in_days = 1
# }

# resource "mongodbatlas_cloud_backup_snapshot_restore_job" "test" {
#   for_each        = toset(var.client_names)
#   project_id      = mongodbatlas_cloud_provider_snapshot.test[each.key].project_id
#   cluster_name    = mongodbatlas_cloud_provider_snapshot.test[each.key].cluster_name
#   snapshot_id     = mongodbatlas_cloud_provider_snapshot.test[each.key].snapshot_id
#   delivery_type_config {
#     download = true
#   }
# }

#############################
# MONGODB USERS
##############################

# DATABASE ADMIN USER  [Configure Database Users](https://docs.atlas.mongodb.com/security-add-mongodb-users/)
resource "mongodbatlas_database_user" "admin" {
  for_each           = toset(var.client_names)
  project_id         = mongodbatlas_project.project[each.key].id
  username           = var.mongodb_atlas_dbadmin
  password           = var.secret_mongodb_atlas_dbadmin_password #var.secret_mongodb_atlas_dbuser_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "modb-${var.Enterprise_product}-${each.value}" # The database name and collection name need not exist in the cluster before creating the user.
  }

  roles {
    role_name     = "dbAdmin"
    database_name = "modb-${var.Enterprise_product}-${each.value}" # The database name and collection name need not exist in the cluster before creating the user.
  }

  labels {
    key   = "Name"
    value = "AppAnalysis DB Admin"
  }
  depends_on = [
    mongodbatlas_project.project,
  ]
}







# DATABASE USER  [Configure Database Users](https://docs.atlas.mongodb.com/security-add-mongodb-users/)
resource "mongodbatlas_database_user" "user" {
  for_each           = toset(var.client_names)
  project_id         = mongodbatlas_project.project[each.key].id
  username           = var.mongodb_atlas_dbuser
  password           = var.secret_mongodb_atlas_dbuser_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "modb-${var.Enterprise_product}-${each.value}" # The database name and collection name need not exist in the cluster before creating the user.
  }
  labels {
    key   = "Name"
    value = "AppAnalysis DB User"
  }
  depends_on = [
    mongodbatlas_project.project,
  ]
}
