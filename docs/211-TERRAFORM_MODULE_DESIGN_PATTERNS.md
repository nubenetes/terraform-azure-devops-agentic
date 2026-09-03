[ Previous: 141. Architecture Adoption and IPAM Guide](141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md) | [ Home](../README.md) | [ Next: 212. Variable Architecture](212-TERRAFORM_VARIABLE_ARCHITECTURE_AND_DATA_STRATEGY.md)

---

# 211. Module Design Patterns

---

##  Table of Contents

- [1. The "Composite" Philosophy](#1-the-composite-philosophy)
    - [1.1 Architectural Comparison](#11-architectural-comparison)
- [2. The Module Versioning Debate: Implicit vs. Explicit](#2-the-module-versioning-debate-implicit-vs-explicit)
    - [2.1 The Current State (Implicit / Local)](#21-the-current-state-implicit--local)
    - [2.2 Advantages of the "Main-as-Stable" Choice](#22-advantages-of-the-main-as-stable-choice)
    - [2.3 Transitioning to Explicit Versioning (Git Tags)](#23-transitioning-to-explicit-versioning-git-tags)
        - [2.3.1 How Git-Tagged Versioning Works:](#231-how-git-tagged-versioning-works)
        - [2.3.2 Why this is superior for Production:](#232-why-this-is-superior-for-production)
    - [2.4 Disadvantages and Risks of the Current Engineering Cost](#24-disadvantages-and-risks-of-the-current-engineering-cost)
    - [2.5 Why it was built this way (The Decision)](#25-why-it-was-built-this-way-the-decision)
- [3. Recommendations for 2026](#3-recommendations-for-2026)
- [4. Validated Reference Library (Official and Community)](#4-validated-reference-library-official-and-community)

---

## 1. The "Composite" Philosophy

The repository rejects the traditional "Atomic Module" pattern (often seen in the Azure Verified Modules - AVM) in favor of **Domain-Driven Composite Modules**.

### 1.1 Architectural Comparison

| Feature | Atomic Modules (AVM Style) | Composite Modules (This Repo) |
| :--- | :--- | :--- |
| **Scope** | Single resource (e.g., `azurerm_storage_account`) | Entire capability (e.g., `App-Core Engine`) |
| **Wiring** | Manual links in the Root module | Pre-wired internal dependencies (RBAC, PE) |
| **Maintenance** | Updates to 20+ independent repos | One surgical commit per domain |
| **Logic** | Simple / Shallow | Deep / Sophisticated (The `Instance Generator`) |

**Why this is a "Good Design" for this project**: 
By bundling the App Service, Key Vault, and its Private Endpoints into a single composite module, we ensure that **Security is non-optional**. A developer cannot "forget" to link the App Service to the VNet, as that logic is baked into the composite manifest.

## 2. The Module Versioning Debate: Implicit vs. Explicit

Currently, the repository uses **Implicit Versioning** (Main-as-Stable). This means the root manifests are tightly coupled to the modules within the same file structure.

### 2.1 The Current State (Implicit / Local)
Modules are called using local relative paths. This ensures that a developer working on a feature can modify both the module logic and the root configuration in a single atomic commit.

**Source of Truth (Evidence)**:

```hcl
module "appcore_logic" {
  source = "./modules/appcore_module" # Local relative path
}
```

### 2.2 Advantages of the "Main-as-Stable" Choice
1. **Simplified Synchronization**: In a Mono-Repo (GitHub), a single commit can update both the module logic and the root manifest simultaneously.
2. **Reduced Version Hell**: Eliminates the overhead of maintaining dozens of independent Git Tags for internal components.
3. **Implicit Trust**: Assumes that if code has reached the `main` branch, it is vetted and stable for all environments.
4. **Development Velocity**: No need to "Release -> Tag -> Bump Source -> PR" for every internal change.

### 2.3 Transitioning to Explicit Versioning (Git Tags)
In a **Federated Multi-Repo** environment (our production design), using local paths creates "Coupled Lifecycles." A breaking change in a networking module could immediately fail an unrelated application pipeline.

#### 2.3.1 How Git-Tagged Versioning Works:
By using the `?ref=` parameter, Terraform can target specific points in the Git history (Tags, Branches, or Commit SHAs).

**Proposed Elite Pattern**:
```hcl
module "vnet_backbone" {
  # Protocols: git::https (for ADO) or git::ssh (for GitHub)
  source = "git::https://dev.azure.com/ORGANIZATION/Shared-Infra//modules/network?ref=v2.1.0"
}
```

#### 2.3.2 Why this is superior for Production:
1. **Immutable Releases**: Environment `PRO` can be pinned to `v1.0.0` while `DEV` experiments with `v2.0.0`.
2. **Decoupled Failures**: Errors in the module's `main` branch do not impact stable stacks until the `source` version is explicitly bumped.
3. **Auditability**: You can trace exactly which version of the "Security Guardrail" was applied to a specific subscription at any time.

### 2.4 Disadvantages and Risks of the Current Engineering Cost
1. **Coupled Failures**: A breaking change in `Shared-Infra` modules immediately breaks the CI/CD of all downstream stacks (`AKS`, `App-Core`) upon their next run.
2. **Impossible Rollbacks**: You cannot easily roll back a single module version for one specific environment without affecting others using the same branch.
3. **Scale Contention**: In a large team (>10 engineers), different teams might need different versions of the "Backbone" networking module simultaneously.

### 2.5 Why it was built this way (The Decision)
The project prioritized **Structural Clarity and DRY Logic** over **Release Decoupling**. Given that the `Instance Generator` in `locals.tf` handles environment isolation (the `d` prefix), the authors felt that branch-based isolation was sufficient to protect production from unvalidated module changes.

## 3. Recommendations for 2026

To transition to an "Elite" level of engineering, we recommend adopting **Explicit Versioning** for the core `Shared-Infra` modules while keeping the `App-Core` business logic modules as local paths.

**Proposed Model**:
```hcl
module "vnet_backbone" {
  # Explicitly pinned to a stable version
  source = "git::https://dev.azure.com/ORGANIZATION/Shared-Infra//modules/network?ref=v2.1.0"
}
```

---

## 4. Validated Reference Library (Official and Community)

- **[HashiCorp: Terraform Module Architecture](https://developer.hashicorp.com/terraform/tutorials/modules/module-architecture)**
- **[HashiCorp: Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)**
- **[HashiCorp: Module Development Principles](https://developer.hashicorp.com/terraform/language/modules/develop)**
- **[HashiCorp Blog: Building Composability with Terraform Modules](https://www.hashicorp.com/blog/building-composability-with-terraform-modules)**
- **[Azure Verified Modules (AVM): Resource Modules (Atomic Pattern)](https://azure.github.io/Azure-Verified-Modules/specs/shared/infrastructure-as-code/resource-modules/)**
- **[Terraform Best Practices: Module Composability](https://www.terraform-best-practices.com/modules)**

---

[ Previous: 141. Architecture Adoption and IPAM Guide](141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md) | [ Home](../README.md) | [ Next: 212. Variable Architecture](212-TERRAFORM_VARIABLE_ARCHITECTURE_AND_DATA_STRATEGY.md)

---

*Technical Documentation: Terraform Module Design Patterns: Composite vs. Atomic | Vision 2026 Architectural Guide*