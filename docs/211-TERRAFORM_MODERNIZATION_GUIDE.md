# 211. Terraform Ecosystem Modernization Guide (September 2026)

[⬅️ Back to README](../README.md) | [Previous: 111. Architecture Strategy](111-ARCHITECTURE_2026_AGENTIC.md) | [Next: 321. Zero-Trust & Pipeline Security](321-ZERO_TRUST_AND_PIPELINE_SECURITY.md)

---

## 1. Modernization Overview

This document details the exact technical upgrades performed in [`nubenetes/terraform-azure-devops-agentic`](https://github.com/nubenetes/terraform-azure-devops-agentic) compared to the base repository [`nubenetes/terraform-azure-devops`](https://github.com/nubenetes/terraform-azure-devops).

> [!NOTE]
> All provider constraints across the 6 root modules and submodules have been upgraded to their September 2026 standards.

---

## 2. Terraform Core Engine Upgrade

*   **Base Version Constraint**: `~> 1.4.5` / `~> 1.5.2`
*   **Modernized Constraint**: `>= 1.9.0, < 2.0.0` (targeting Terraform 1.10+ / 1.15+ / 1.16)

### Key HCL Capabilities Unlocked:
1.  **Continuous Validation (`check` blocks)**: Allows assertions against real-world infrastructure health without modifying state.
2.  **Declarative `import` blocks**: Eliminates imperative `terraform import` CLI commands, bringing existing resources into code via version-controlled HCL.
3.  **Declarative `removed` blocks**: Enables safe resource retirement without requiring manual state editing (`terraform state rm`).
4.  **Cross-Object Validation**: Variable validation rules can now reference other variables and local values to enforce interdependent constraints.

---

## 3. AzureRM Provider v4.x Migration

*   **Base Version**: `~> 3.62.1` / `~> 3.63.0`
*   **Modernized Version**: `~> 4.0`

### Breaking Changes & Mitigations:
1.  **Removal of `features.resource_group.prevent_deletion_if_contains_resources`**:
    *   *Base Repo*: Set explicitly to `false` or `true` within the provider features block.
    *   *Modernized*: Removed from provider configuration. Resource group deletion behavior is now governed by explicit resource dependencies and Azure API lifecycle standards.
2.  **Storage Account TLS Configuration**:
    *   *Base Repo*: Used deprecated `enable_https_traffic_only = true`.
    *   *Modernized*: Replaced with `min_tls_version = "TLS1_2"` in [`07-storage-account.tf`](../App-Core/terraform-manifests/modules/appcore_module/07-storage-account.tf). HTTPS is enforced natively by AzureRM v4.
3.  **App Service Modernization**:
    *   *Base & Modernized*: Standardized on `azurerm_linux_web_app` and `azurerm_service_plan`, completely retiring legacy `azurerm_app_service`.

---

## 4. Microsoft Entra ID (AzureAD Provider v3.x)

*   **Base Version**: `~> 2.39.0`
*   **Modernized Version**: `~> 3.0`

### Modernization Highlights:
1.  **Native Microsoft Graph API v1.0**: Completely eliminates all legacy Azure Active Directory Graph dependencies.
2.  **App Role Assignments**: Streamlined permissions syntax for service principals and app registrations.
3.  **Workload Identity Federation**: Ready for secretless federated credentials via `azuread_application_federated_identity_credential`.

---

## 5. Kubernetes & Random Providers

| Provider | Base Constraint | Modernized Constraint | Rationale |
| :--- | :--- | :--- | :--- |
| `hashicorp/kubernetes` | `~> 2.21.1` | `~> 2.32.0` | Support for modern AKS clusters (K8s 1.28+) and dynamic kubelogin token plugins. |
| `hashicorp/random` | `~> 3.5.1` | `~> 3.6.2` | Stability and provider updates. |
| `hashicorp/helm` | `~> 2.10.1` | `~> 2.15.0` | Support for Helm 3.14+ and modernized chart repositories. |

---

*Enterprise Architecture Blueprint | Vision 2026*
