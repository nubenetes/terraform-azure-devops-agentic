# https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/manage-with-terraform
# https://learn.microsoft.com/en-us/azure/cosmos-db/migration-choices
# https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/tutorial-mongotools-cosmos-db
# https://stackoverflow.com/questions/65815895/mongoimport-and-mongorestore-wont-connect-to-cosmosdb-3-6-retrywrites-option-i

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account
# https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/cli-samples

# https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/tutorial-mongotools-cosmos-db

# Boilerplate:
# https://github.com/claranet/terraform-azurerm-cosmos-db/blob/master/r-cosmosdb.tf
# https://github.com/SvanBoxel/organization-workflows/blob/732988317786f072bed1ebfeeb3c73868ba68704/infra/cosmos.tf

# https://prashix.medium.com/provision-cosmosdb-in-azure-using-terraform-54179c720872
# Offer_type is standard and that’s the only choice, ‘kind’ defaulted to “GlobalDocumentDB” and the other kind is “MongoDB.
# ‘Consistency_policy’ basically defines that data consistency requirements for this account, it has the following options:
# - Eventual doesn’t guarantee any ordering and only ensures that replicas will eventually converge
# - Consistent prefix adds ordering guarantees on top of eventual
# - Session is scoped to a single client connection and basically ensures a read-your-own-writes consistency for each client; it is the default consistency level
# - Bounded staleness augments consistent prefix by ensuring that reads won’t lag beyond x versions of an item or some specified time window
# - Strong consistency (or linearizable) ensures that clients always read the latest globally committed write

resource "azurerm_cosmosdb_account" "db" {
  name                      = "cosmosdb-account-${var.enterprise_product}-${local.instance_environment}"
  location                  = azurerm_resource_group.appcore_rg.location
  resource_group_name       = azurerm_resource_group.appcore_rg.name
  offer_type                = "Standard"
  kind                      = "MongoDB"
  mongo_server_version      = "4.2" # https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/feature-support-42
  enable_automatic_failover = true
  tags                      = local.tags

  # https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/how-to-configure-capabilities
  capabilities {
    name = "EnableAggregationPipeline" # https://azure.microsoft.com/en-gb/blog/azure-cosmosdb-extends-support-for-mongodb-aggregation-pipeline-unique-indexes-and-more/
  }

  # capabilities {
  #   name = "mongoEnableDocLevelTTL" # https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/time-to-live
  # }
  capabilities {
    name = "EnableMongo"
  }
  capabilities {
    name = "DisableRateLimitingResponses"
  }
  capabilities {
    name = "EnableMongoRoleBasedAccessControl"
  }
  capabilities {
    name = "EnableMongoRetryableWrites"
  }
  capabilities {
    name = "EnableMongo16MBDocumentSupport"
  }
  capabilities {
    name = "EnableUniqueCompoundNestedDocs"
  }

  ##############################
  # Consistency Levels/Policy
  ##############################
  # https://learn.microsoft.com/en-us/azure/cosmos-db/consistency-levels

  # consistency_policy {
  #   consistency_level       = "BoundedStaleness"
  #   max_interval_in_seconds = 300
  #   max_staleness_prefix    = 100000
  # }
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.appcore_rg.location
    failover_priority = 0
  }
  # geo_location {
  #   location          = "westeurope" #"eastus"
  #   failover_priority = 0
  # }

  # geo_location {
  #   location          = "uksouth" #"westus"
  #   failover_priority = 1
  # }
}

data "azurerm_cosmosdb_account" "db" {
  name                = azurerm_cosmosdb_account.db.name
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
}

resource "azurerm_cosmosdb_mongo_database" "db" {
  for_each            = toset(var.client_names)
  name                = "modb-${var.enterprise_product}-${each.value}"
  resource_group_name = data.azurerm_cosmosdb_account.db.resource_group_name
  account_name        = data.azurerm_cosmosdb_account.db.name
  throughput          = 400
}


#########################################################################################################
# mongoimport: If the collection already exists mongoimport will drop the existing collection first
#########################################################################################################
# resource "azurerm_cosmosdb_mongo_collection" "config_appcore" {
#   name                = "config.appcore"
#   resource_group_name = data.azurerm_cosmosdb_account.db.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.db.name
#   database_name       = azurerm_cosmosdb_mongo_database.db[each.key].name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }

# resource "azurerm_cosmosdb_mongo_collection" "enterprise_units" {
#   name                = "enterprise.units"
#   resource_group_name = data.azurerm_cosmosdb_account.db.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.db.name
#   database_name       = azurerm_cosmosdb_mongo_database.db[each.key].name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }

# resource "azurerm_cosmosdb_mongo_collection" "pipeline_definitions" {
#   name                = "pipeline.definitions"
#   resource_group_name = data.azurerm_cosmosdb_account.db.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.db.name
#   database_name       = azurerm_cosmosdb_mongo_database.db[each.key].name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }

# resource "azurerm_cosmosdb_mongo_collection" "series_rules" {
#   name                = "series.rules"
#   resource_group_name = data.azurerm_cosmosdb_account.db.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.db.name
#   database_name       = azurerm_cosmosdb_mongo_database.db[each.key].name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }

# resource "azurerm_cosmosdb_mongo_collection" "series_standards" {
#   name                = "series.standards"
#   resource_group_name = data.azurerm_cosmosdb_account.db.resource_group_name
#   account_name        = data.azurerm_cosmosdb_account.db.name
#   database_name       = azurerm_cosmosdb_mongo_database.db[each.key].name

#   default_ttl_seconds = "777"
#   shard_key           = "uniqueKey"
#   throughput          = 400

#   index {
#     keys   = ["_id"]
#     unique = true
#   }
# }


####################################################################################################################################
# https://www.hashicorp.com/blog/terraform-1-4-improves-the-cli-experience-for-terraform-cloud
# https://developer.hashicorp.com/terraform/language/resources/terraform-data
# Terraform 1.4 introduces a new terraform_data resource as a built-in replacement for the null resource.
# This removes the need to include the null provider in your configuration and supports all the same capabilities as null_resource
####################################################################################################################################

resource "terraform_data" "cosmos_mongodb_instance_per_client" {
  for_each = toset(var.client_names)
  # Replacement of any instance of the cosmosdb account requires re-provisioning
  #triggers_replace = azurerm_cosmosdb_account.db[0].name
  # Replacement of any instance of the cosmosdb database requires re-provisioning
  triggers_replace = azurerm_cosmosdb_mongo_database.db[each.key].id

  provisioner "local-exec" {
    ###########################################################################################
    # Creation-time provisioner:
    # https://k21academy.com/terraform-iac/terraform-provisioners/
    # https://www.terraform.io/language/resources/provisioners/connection
    # https://www.terraform.io/language/resources/provisioners/null_resource
    # https://learn.microsoft.com/en-us/azure/cosmos-db/mongodb/tutorial-mongotools-cosmos-db
    ############################################################################################
    command = "chmod +x creation-time-provisioner-cosmosdb.sh;./creation-time-provisioner-cosmosdb.sh '${azurerm_cosmosdb_account.db.connection_strings[0]}' modb-${var.enterprise_product}-${each.value} ${var.environment}"
  }
  # depends_on = [
  #   azurerm_cosmosdb_mongo_database.db,
  # ]
}
