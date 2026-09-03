# Proof of Concept: Azure Cosmos DB for MongoDB API

This Proof of Concept (POC) explores the migration path from MongoDB Atlas to **Azure Cosmos DB for MongoDB API** within the App-Core ecosystem.

## 🎯 Why Azure Cosmos DB for MongoDB?

The shift from a cross-cloud PaaS (MongoDB Atlas) to a native Azure service (Cosmos DB) is driven by several architectural advantages:

### ✅ Advantages
- **Native Azure Integration**: Simplified governance via Azure Policy and seamless integration with Defender for Cloud.
- **Zero-Trust Security**: Native support for **Azure RBAC** (Microsoft Entra ID), eliminating the need for local database user management and rotating connection string secrets.
- **Network Sovereignty**: First-class support for **Azure Private Endpoints**, keeping all database traffic within the private VNet backbone without requiring complex VPC peering or IP whitelisting.
- **Consolidated Billing**: Single-pane-of-glass for cost management within the Azure EA/MCA.
- **Unified Management**: Infrastructure managed 100% via the `azurerm` Terraform provider, reducing dependency on the `mongodbatlas` provider.

### ❌ Considerations (Trade-offs)
- **Feature Lag**: While Cosmos DB for MongoDB has reached significant parity, some niche MongoDB-native features or specific indexing strategies may behave differently.
- **Cost Model**: Transitioning from Atlas's tier-based pricing to Cosmos DB's **Request Units (RU/s)** or **vCore** model requires careful capacity planning.

## 🔄 Functional Equivalence & Compatibility

Historically, Cosmos DB for MongoDB had limitations in pipeline aggregation and operator support. However, with the introduction of **version 4.2, 5.0, and the latest 6.0 support**, the two platforms have reached a high degree of functional equivalence:

- **MongoDB 4.2+ Compatibility**: Key milestones included support for multi-document transactions and enhanced aggregation pipelines.
- **2023-2024 Enhancements**: Native support for 16MB document sizes, advanced indexing, and role-based access control made Cosmos DB a viable 1:1 replacement for most enterprise MongoDB workloads.

## 🏗 Updated Architecture

In this POC, the persistence fabric shifts from a cross-cloud dependency to a native Azure resource:
1. **Core API** connects to **Cosmos DB** via **Private Link**.
2. **Authentication** is handled via **Managed Identity** (OIDC), leveraging Azure RBAC.
3. **Initialization** is orchestrated via the `creation-time-provisioner-cosmosdb.sh` script during the Terraform lifecycle.

## 📁 Minimal POC Structure

To maintain a clean repository, this POC only includes the logic that differs from the base `App-Core`:

- **New Module**: `terraform-manifests/modules/appcore_module/29-cosmosdb-mongodb.tf` - Provisions the Cosmos DB account.
- **New Provisioner**: `terraform-manifests/creation-time-provisioner-cosmosdb.sh` - Handles database initialization.
- **Modified Manifests**: `main.tf`, `variables.tf`, and `outputs.tf` updated for CosmosDB integration.
- **Specific Configuration**: Independent `.tfvars` and pipelines for this POC environment.

## 🚀 How to use

The POC pipelines are:
- `01-terraform-provision-appcore-cosmosdb-pipeline.yml`
- `02-terraform-destroy-appcore-cosmosdb-pipeline.yml`
