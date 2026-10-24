[⬅️ Previous: 213. Configuration Inventory](213-TERRAFORM_ENVIRONMENT_CONFIGURATION_AND_TFVARS_INVENTORY.md) | [🏠 Home](../README.md) | [➡️ Next: 221. Visualizations](221-TERRAFORM_VISUALIZATIONS_AND_DEPENDENCY_GRAPHS.md)

---

# 214. Terraform Modernization Guide

---

## 📑 Table of Contents

- [Modernization Overview](#1-modernization-overview)
- [Terraform Core Engine Upgrade (1.9+ / 1.15+ / 1.16+)](#2-terraform-core-engine-upgrade-19--115--116)
    - [Key HCL Capabilities Unlocked](#21-key-hcl-capabilities-unlocked)
    - [Replacement of Archived data template_file with Native templatefile()](#22-replacement-of-archived-data-template_file-with-native-templatefile)
    - [Declarative check, removed, and Cross-Variable validation Blocks](#23-declarative-check-removed-and-cross-variable-validation-blocks)
- [AzureRM Provider v4.0 Migration](#3-azurerm-provider-v40-migration)
    - [Provider Configuration: resource_provider_registrations](#31-provider-configuration-resource_provider_registrations)
    - [Comprehensive AzureRM v4.0 Schema Changes Matrix](#32-comprehensive-azurerm-v40-schema-changes-matrix)
    - [Defender for Cloud: Retiring azurerm_security_center_auto_provisioning](#33-defender-for-cloud-retiring-azurerm_security_center_auto_provisioning)
- [Microsoft Entra ID (AzureAD Provider v3.0) Migration](#4-microsoft-entra-id-azuread-provider-v30-migration)
    - [Comprehensive AzureAD v3.0 Schema Changes Matrix](#41-comprehensive-azuread-v30-schema-changes-matrix)
    - [Compound Identity and OAuth2 Pre-Authorization Updates](#42-compound-identity-and-oauth2-pre-authorization-updates)
- [Kubernetes, Helm, and Random Providers](#5-kubernetes-helm-and-random-providers)
    - [Provider Version Matrix](#51-provider-version-matrix)
    - [Kubernetes Exec Plugin v1 and Kubelogin Modernization](#52-kubernetes-exec-plugin-v1-and-kubelogin-modernization)

---

## 1. Modernization Overview

This document details the exact technical upgrades performed in [`nubenetes/terraform-azure-devops-agentic`](https://github.com/nubenetes/terraform-azure-devops-agentic) compared to the base repository [`nubenetes/terraform-azure-devops`](https://github.com/nubenetes/terraform-azure-devops).

> [!NOTE]
> All provider constraints across the 6 root modules and submodules have been upgraded to their September 2026 standards (`Terraform >= 1.9.0, < 2.0.0`, `AzureRM ~> 4.0`, `AzureAD ~> 3.0`, `MongoDB Atlas ~> 1.25.0`, `Kubernetes ~> 2.32.0`, `Helm ~> 2.15.0`).

---

## 2. Terraform Core Engine Upgrade (1.9+ / 1.15+ / 1.16+)

*   **Base Version Constraint**: `~> 1.4.5` / `~> 1.5.2`
*   **Modernized Constraint**: `>= 1.9.0, < 2.0.0` (targeting Terraform 1.10+ / 1.15+ / 1.16+ and OpenTofu 1.8+)

### 2.1 Key HCL Capabilities Unlocked
1.  **Continuous Validation (`check` blocks)**: Allows post-provisioning assertions against real-world infrastructure health and configuration invariants without modifying or halting state.
2.  **Declarative `import` blocks**: Eliminates imperative `terraform import` CLI commands, bringing existing Azure and Entra ID resources into code via version-controlled HCL.
3.  **Declarative `removed` blocks**: Enables safe resource retirement from Terraform state (`lifecycle { destroy = false }`) without requiring manual `terraform state rm` operations in CI/CD pipelines.
4.  **Cross-Variable `validation` blocks**: Variable validation `condition` expressions can now reference other input variables (`var.*`) and local values (`local.*`) to enforce interdependent architectural constraints at plan time (introduced in Terraform 1.9+).

### 2.2 Replacement of Archived data template_file with Native templatefile()
The legacy `hashicorp/template` provider and its `data "template_file"` resource have been archived and lack binaries for modern platforms (such as `darwin_arm64` and `linux_arm64`). All dynamic script and configuration rendering has been migrated to Terraform's built-in `templatefile("${path.module}/...", { ... })` function, eliminating external provider dependencies.

### 2.3 Declarative check, removed, and Cross-Variable validation Blocks
```hcl
# Cross-variable validation (Terraform 1.9+)
variable "environment" {
  type = string
  validation {
    condition     = !(var.gitbranch == "main" && contains(["dev", "qa", "uat"], var.environment))
    error_message = "Production main branch pipelines cannot target engineering environments."
  }
}

# Continuous architectural health assertion (check block)
check "storage_tls_compliance" {
  assert {
    condition     = azurerm_storage_account.storage_account.min_tls_version == "TLS1_2"
    error_message = "Storage account must enforce minimum TLS 1.2 encryption."
  }
}
```

---

## 3. AzureRM Provider v4.0 Migration

*   **Base Version**: `~> 3.62.1` / `~> 3.63.0`
*   **Modernized Version**: `~> 4.0`

### 3.1 Provider Configuration: resource_provider_registrations
In AzureRM v4.0, automatic registration of all Azure Resource Providers is disabled or requires subscription-wide owner permissions that violate Zero-Trust least-privilege CI/CD principles:
*   **`resource_provider_registrations = "none"`**: Explicitly configured in all `provider "azurerm"` blocks (`skip_provider_registration` is deprecated and removed in v4.0).
*   **Removal of `features.resource_group.prevent_deletion_if_contains_resources`**: Removed from provider blocks where applicable to adhere to clean v4.0 lifecycle management.

### 3.2 Comprehensive AzureRM v4.0 Schema Changes Matrix

| Resource Type | Legacy v3.x Attribute / Block | Modern v4.0 Attribute / Block | Affected Modules |
| :--- | :--- | :--- | :--- |
| `provider "azurerm"` | `skip_provider_registration = true` | `resource_provider_registrations = "none"` | All Root Modules |
| `azurerm_kubernetes_cluster` | `enable_auto_scaling = true` | `auto_scaling_enabled = true` | `AKS` |
| `azurerm_kubernetes_cluster` (`api_server_access_profile`) | `vnet_integration_enabled = true` | `virtual_network_integration_enabled = true` | `AKS` |
| `azurerm_kubernetes_cluster_node_pool` | `enable_auto_scaling = true` | `auto_scaling_enabled = true` | `AKS` |
| `azurerm_application_gateway` | `enable_http2 = true` | `http2_enabled = true` | `App-Core`, `App-Catalog` |
| `azurerm_storage_account` | `enable_https_traffic_only = true` | `https_traffic_only_enabled = true` and `min_tls_version = "TLS1_2"` | `App-Core`, `App-Catalog`, `Shared-Infra` |
| `azurerm_storage_container` | `storage_account_name` and `.resource_manager_id` | `storage_account_id` and `.id` | `App-Core`, `App-Catalog` |
| `azurerm_key_vault` | `enable_rbac_authorization = true` | `rbac_authorization_enabled = true` | `App-Core`, `App-Catalog`, `Shared-Infra` |
| `azurerm_log_analytics_workspace` | `local_authentication_disabled = true` | `local_authentication_enabled = false` | `App-Core`, `App-Catalog` |
| `azurerm_recovery_services_vault` | `soft_delete_enabled = false` | Attribute removed (soft delete enforced by default in v4.0) | `App-Catalog`, `App-Core` |
| `azurerm_private_dns_zone_virtual_network_link` | `private_dns_zone_id` (or DNS zone link) | `dns_zone_ids = [...]` (on `private_dns_zone_group`) | `App-Core`, `Shared-Infra` |
| `azurerm_backup_protected_file_share` | `source_storage_account_id` | `storage_account_id` | `App-Core`, `App-Catalog` |
| `azurerm_linux_web_app` | `docker_image` + `docker_image_tag` | `application_stack { docker_image_name = "${image}:${tag}" }` | `App-Core`, `App-Catalog` |
| `azurerm_cosmosdb_account` | `enable_automatic_failover = true` | `automatic_failover_enabled = true` | `App-Core` (Cosmos DB PoC) |
| `azurerm_security_center_contact` | Implicit singleton | Explicit `name = "default"` required in v4.0 | `Shared-Infra` |

### 3.3 Defender for Cloud: Retiring azurerm_security_center_auto_provisioning
 Microsoft Azure deprecated the legacy Log Analytics agent auto-provisioning API, and `azurerm_security_center_auto_provisioning` was removed in AzureRM v4.0. Rather than breaking existing state files, [`Shared-Infra`](../Shared-Infra/terraform-manifests/modules/shared_module/05-azure-defender.tf) uses a declarative `removed` block:
```hcl
removed {
  from = azurerm_security_center_auto_provisioning.auto-provisioning

  lifecycle {
    destroy = false
  }
}
```

---

## 4. Microsoft Entra ID (AzureAD Provider v3.0) Migration

*   **Base Version**: `~> 2.39.0`
*   **Modernized Version**: `~> 3.0`

### 4.1 Comprehensive AzureAD v3.0 Schema Changes Matrix
The AzureAD v3.0 provider aligns 100% with Microsoft Graph API v1.0 and introduces strict distinction between Application Client IDs (`client_id`), Directory Object GUIDs (`object_id`), and Terraform Resource URIs (`id`, formatted as `/applications/<object-id>`):

| Resource / Data Source | Legacy v2.x Attribute | Modern v3.0 Attribute | Technical Rationale |
| :--- | :--- | :--- | :--- |
| `azuread_application` / `azuread_service_principal` | `.application_id` | `.client_id` | Standardized on OAuth 2.0 `client_id` terminology across all resources and data sources. |
| `azuread_application_password` | `application_object_id = azuread_application.app.object_id` | `application_id = azuread_application.app.id` | Requires the full Terraform resource ID URI (`/applications/{object_id}`) instead of bare GUID. |
| `azuread_application_pre_authorized` | `application_object_id` and `authorized_app_id` | `application_id = ...id` and `authorized_client_id = ...client_id` | Separates target application resource URI (`application_id`) from authorized client ID (`authorized_client_id`). |
| `azuread_service_principal` | `application_id = azuread_application.app.application_id` | `client_id = azuread_application.app.client_id` | Links Service Principal to Application Registration via `client_id`. |
| `azuread_user` / `azuread_group` | `.id` (used as GUID in v2.x) | `.object_id` (for RBAC and Key Vault policies) | In v3.0, `.id` returns a Graph path URI (`/users/{id}`), whereas Azure RBAC and Key Vault require the raw GUID `.object_id`. |

### 4.2 Compound Identity and OAuth2 Pre-Authorization Updates
```hcl
resource "azuread_application_pre_authorized" "pre_auth" {
  application_id       = azuread_application.backend_api.id
  authorized_client_id = azuread_application.frontend_spa.client_id
  permission_ids       = [random_uuid.scope_id.result]
}
```

---

## 5. Kubernetes, Helm, and Random Providers

### 5.1 Provider Version Matrix

| Provider | Base Constraint | Modernized Constraint | Rationale |
| :--- | :--- | :--- | :--- |
| `hashicorp/kubernetes` | `~> 2.21.1` | `~> 2.32.0` | Support for modern AKS clusters (K8s 1.30+) and `client.authentication.k8s.io/v1` exec plugin. |
| `hashicorp/helm` | `~> 2.10.1` | `~> 2.15.0` | Support for Helm 3.15+, OCI chart registries, and modernized kubeconfig exec blocks. |
| `hashicorp/random` | `~> 3.5.1` | `~> 3.6.2` | Stability and UUID generation for Entra ID app roles and OAuth2 scopes. |

### 5.2 Kubernetes Exec Plugin v1 and Kubelogin Modernization
Kubernetes 1.24+ removed the legacy `client.authentication.k8s.io/v1beta1` API version, and modern `kubelogin` releases removed the deprecated `--environment AzurePublicCloud` flag. Both [`AKS`](../AKS/terraform-manifests/01-main.tf) and [`Day2-ops`](../Day2-ops/terraform-manifests/01-main.tf) provider `exec` blocks have been modernized to `client.authentication.k8s.io/v1`:
```hcl
exec {
  api_version = "client.authentication.k8s.io/v1"
  command     = "kubelogin"
  args = [
    "get-token",
    "--login",
    "spn",
    "--server-id",
    var.aks_aad_server_app_id,
    "--client-id",
    var.client_id,
    "--client-secret",
    var.client_secret,
    "--tenant-id",
    var.tenant_id
  ]
}
```

---

## 📚 Validated Reference Library (Official and Community)

*   **[AzureRM Provider v4.0 Upgrade Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide)**: Official HashiCorp guide covering `resource_provider_registrations`, boolean attribute renames (`*_enabled`), and removed resources.
*   **[AzureAD Provider v3.0 Upgrade Guide](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/3.0-upgrade-guide)**: Official guide detailing the transition to Microsoft Graph v1.0, `.client_id`, and resource URI `.id` vs `.object_id`.
*   **[HashiCorp Terraform 1.9+ Release Notes (Cross-Variable Validation)](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules)**: Referencing other variables and locals inside variable validation blocks.
*   **[HashiCorp Terraform Continuous Validation (check Blocks)](https://developer.hashicorp.com/terraform/language/checks)**: Writing infrastructure health assertions with `check` blocks.
*   **[HashiCorp Terraform Declarative Resource Removal (removed Blocks)](https://developer.hashicorp.com/terraform/language/resources/syntax#removing-resources)**: Retiring resources from state cleanly without imperative CLI operations.
*   **[Azure Kubelogin Documentation](https://azure.github.io/kubelogin/)**: Exec credential plugin (`client.authentication.k8s.io/v1`) for Azure Kubernetes Service authentication.

---

[⬅️ Previous: 213. Configuration Inventory](213-TERRAFORM_ENVIRONMENT_CONFIGURATION_AND_TFVARS_INVENTORY.md) | [🏠 Home](../README.md) | [➡️ Next: 221. Visualizations](221-TERRAFORM_VISUALIZATIONS_AND_DEPENDENCY_GRAPHS.md)

---

*Technical Documentation: Terraform Ecosystem Modernization Guide | Vision 2026 Architectural Guide*
