[⬅️ Previous: 324. Security-by-Design Checklist](324-SECURITY_BY_DESIGN_CHECKLIST.md) | [🏠 Home](../README.md) | [➡️ Next: 331. AKS Compute Hub](331-AKS_COMPUTE_HUB_AND_ML_ORCHESTRATION.md)

---

# 325. Zero-Trust and Pipeline Security

---

## 📑 Table of Contents

- [Security Architecture Overview](#1-security-architecture-overview)
    - [Diagram Description and Zero-Trust Security Breakdown](#11-diagram-description-and-zero-trust-security-breakdown)
    - [Summary and Key Takeaways](#12-summary-and-key-takeaways)
    - [Conclusion](#13-conclusion)
- [Security Vulnerabilities Identified in Base Architecture and Modernized Solutions](#2-security-vulnerabilities-identified-in-base-architecture-and-modernized-solutions)
    - [Vulnerability 1: Plaintext Secrets in Command-Line Arguments](#21-vulnerability-1-plaintext-secrets-in-command-line-arguments)
    - [Vulnerability 2: Long-Lived Service Principal Client Secrets](#22-vulnerability-2-long-lived-service-principal-client-secrets)
    - [Vulnerability 3: Deprecated Pipeline Runner Operating Systems](#23-vulnerability-3-deprecated-pipeline-runner-operating-systems)
    - [Vulnerability 4: Insecure Binary Downloads without Checksum Verification](#24-vulnerability-4-insecure-binary-downloads-without-checksum-verification)
- [Least Privilege and Compound Authentication](#3-least-privilege-and-compound-authentication)
    - [App-Plus-User Compound Identity Pattern](#31-app-plus-user-compound-identity-pattern)

---

## 1. Security Architecture Overview

This document presents the security review and hardening strategy implemented in [`nubenetes/terraform-azure-devops-agentic`](https://github.com/nubenetes/terraform-azure-devops-agentic), transitioning the architecture from legacy secret-based workflows to a **Zero-Trust, Secretless CI/CD model**.

<details>
<summary><b>📊 Click to expand Diagram: Security Architecture Overview</b></summary>

```mermaid
flowchart TD
    subgraph Identity_Plane ["Microsoft Entra ID (Zero-Trust Identity)"]
        FedCred["Federated Credentials<br/>(OIDC Trust)"]
        SPN["Managed Service<br/>Principal (MSI)"]
        CSA["Custom Security<br/>Attributes (ABAC)"]
    end
    subgraph Pipeline_Plane ["Hardened Azure DevOps Pipeline (ubuntu-latest)"]
        Runner["Pipeline Agent<br/>(Ubuntu 24.04 LTS)"]
        MaskedEnv["Masked Env Vars<br/>(TF_VAR_*)"]
        Scan["Static Security Gate<br/>(Checkov / Trivy)"]
        Approval["Approval Gate<br/>(ManualValidation@0)"]
    end
    subgraph Azure_Plane ["Azure Landing Zone"]
        KeyVault["Azure Key Vault<br/>(RBAC and Purge)"]
        AKS["AKS Compute<br/>(Workload Identity)"]
        Storage["Storage Account<br/>(TLS 1.2+ Private Link)"]
    end
    Runner --> Scan
    Scan --> MaskedEnv
    MaskedEnv --> Approval
    Approval --> Runner
    Runner -->|Request OIDC Token| FedCred
    FedCred -->|Exchange for ARM Token| SPN
    SPN --> KeyVault
    SPN --> AKS
    SPN --> Storage
```

</details>

### 1.1 Diagram Description and Zero-Trust Security Breakdown
*   **Identity Plane (Microsoft Entra ID)**: Manages `Federated Identity Credentials (OIDC)`, exchanging ephemeral tokens with `Managed Service Principals` and enforcing directory-level `Custom Security Attributes`.
*   **Pipeline Plane (Azure DevOps)**: Executes on hardened `Ubuntu 24.04 LTS` runners, performs automated `Checkov` and `Trivy` static analysis, reads credentials strictly via masked `TF_VAR_*` environment variables, and halts at `ManualValidation@0` approval gates.
*   **Azure Landing Zone Target**: Grants scoped, secretless access to `Azure Key Vault (RBAC and Purge Protection)`, `AKS Compute (Workload Identity)`, and `Azure Storage (TLS 1.2+ and Private Link)`.

### 1.2 Summary and Key Takeaways
*   **Zero Static Passwords**: Long-lived service principal client secrets are completely eliminated.
*   **Automated Quality and Compliance Gates**: Static code scanning and human authorization block unauthorized modifications.
*   **Cryptographic Workload Identity**: Short-lived OIDC tokens govern all deployment and runtime access.

### 1.3 Conclusion
The modernized security framework establishes an auditable Zero-Trust baseline that eliminates credential leakage vectors and automates security governance across the entire infrastructure lifecycle.

---

## 2. Security Vulnerabilities Identified in Base Architecture and Modernized Solutions

### 2.1 Vulnerability 1: Plaintext Secrets in Command-Line Arguments
*   **Base Repo Anti-Pattern**: In `templates/terraform-plan.yml` and `templates/terraform-apply.yml`, secrets were passed directly via `-var secret_...=$(...)` in `commandOptions`.
*   **Security Risk**: Command-line arguments are stored in plaintext in the operating system's process table (`ps aux`, `/proc/<pid>/cmdline`), accessible to any compromised process or logging agent running on self-hosted runners. Furthermore, unmasked pipeline debug logs expose the secrets in task execution traces.
*   **Modernized Solution**: All sensitive variables are mapped to the task `env:` block as `TF_VAR_secret_name: $(secret_variable)`. Terraform natively ingests `TF_VAR_*` variables directly into memory without exposing them on the command-line interface.

### 2.2 Vulnerability 2: Long-Lived Service Principal Client Secrets
*   **Base Repo Anti-Pattern**: Service connections relied on static client secrets (`client_secret`), requiring ongoing password rotation, expiration tracking, and key vault storage.
*   **Modernized Solution**: Implementation of **Workload Identity Federation (OIDC)** via `ARM_USE_OIDC: "true"`. The Azure DevOps pipeline agent requests a cryptographically signed OIDC token from Azure DevOps, which Microsoft Entra ID validates against configured federated credentials. Zero long-lived passwords exist in Azure DevOps.

### 2.3 Vulnerability 3: Deprecated Pipeline Runner Operating Systems
*   **Base Repo Anti-Pattern**: All pipelines were pinned to `vmImage: 'ubuntu-20.04'`.
*   **Security Risk**: Ubuntu 20.04 is End-of-Life (EOL), lacking security patches for core system utilities, OpenSSL, and kernel mitigations.
*   **Modernized Solution**: Upgraded to `vmImage: 'ubuntu-latest'` (Ubuntu 24.04 LTS), guaranteeing access to modern TLS 1.3 libraries, active security patching, and modern container runtimes.

### 2.4 Vulnerability 4: Insecure Binary Downloads without Checksum Verification
*   **Base Repo Anti-Pattern**: Pipeline steps downloaded external binaries via `wget $(KUBELOGIN_DOWNLOAD_URL) && unzip && sudo mv /usr/bin`.
*   **Security Risk**: Vulnerable to man-in-the-middle attacks or DNS hijacking, allowing arbitrary remote code execution on CI/CD agents.
*   **Modernized Solution**: Shifted to official Azure DevOps task installers or verified package managers with cryptographic hash checks.

---

## 3. Least Privilege and Compound Authentication

### 3.1 App-Plus-User Compound Identity Pattern
In [`App-Core/terraform-manifests/modules/appcore_module/23-key-vault-clients.tf`](../App-Core/terraform-manifests/modules/appcore_module/23-key-vault-clients.tf), access to client-specific Key Vaults is governed by compound identity rules:
```hcl
access_policy {
  tenant_id      = var.aad_tenant_id
  object_id      = azuread_user.testuser1.object_id
  application_id = azuread_application.appcore_back_api.client_id

  secret_permissions = [
    "Get",
    "List",
  ]
}
```
*Effect*: An attacker possessing a leaked user token cannot decrypt secrets unless the request also originates from the authorized Application Service Principal.

---

## 📚 Validated Reference Library (Official and Community)

*   **[Microsoft Entra Workload ID Federation Overview](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation)**: Official architecture guide for secretless OIDC token exchange between external CI/CD platforms and Azure.
*   **[Azure DevOps Service Connections using Workload Identity Federation](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure)**: Configuring passwordless Azure Resource Manager service connections in Azure Pipelines.
*   **[HashiCorp Terraform Environment Variables (TF_VAR_*)](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_var_name)**: Passing sensitive variables securely into Terraform memory without CLI process table exposure.
*   **[Azure Key Vault Access Policy Compound Identity](https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy)**: Implementing App-plus-User compound authentication with `application_id` and `object_id`.
*   **[Checkov Static Code Analysis for Terraform](https://www.checkov.io/)**: Policy-as-Code scanning for Azure and Kubernetes manifests in CI/CD pipelines.

---

[⬅️ Previous: 324. Security-by-Design Checklist](324-SECURITY_BY_DESIGN_CHECKLIST.md) | [🏠 Home](../README.md) | [➡️ Next: 331. AKS Compute Hub](331-AKS_COMPUTE_HUB_AND_ML_ORCHESTRATION.md)

---

*Technical Documentation: Zero-Trust Architecture and Pipeline Security Hardening | Vision 2026 Architectural Guide*
