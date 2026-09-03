# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0-agentic] - 2026-09-03

### Added
- **Agentic PoC & Reference Architecture Baseline**: Complete modernization by **Antigravity Gemini 3.8 Flash agent** as an untested proof-of-concept and blueprint.
- **In-Depth Terraform Stacks Incompatibility Analysis**: Added comprehensive documentation and architectural diagrams explaining why HashiCorp Terraform Stacks is unavailable on this architecture (HCP SaaS lock-in, CI/CD pipeline conflict, imperative script interleaving, data sovereignty).
- **Native Mermaid Architecture Visualizations**: Replaced binary media with 6 rich Mermaid diagrams in `README.md` and `docs/` (Global Architecture, DevSecOps Multi-Stage Flow, State Dependency Graph, Zero-Trust OIDC Identity Flow, Stacks Comparison, MongoDB Atlas Topology).
- **New Modernization Documentation Suite**: Added `docs/113-ARCHITECTURE_2026_AGENTIC.md`, `docs/214-TERRAFORM_MODERNIZATION_GUIDE.md`, `docs/325-ZERO_TRUST_AND_PIPELINE_SECURITY.md`, and `docs/343-MONGODB_ATLAS_MODERNIZATION.md`.

### Changed
- **Terraform Core Upgrade**: Modernized `required_version` across all root manifests and modules to `>= 1.9.0, < 2.0.0` (targeting 1.10+ / 1.15+ standards).
- **AzureRM Provider v4.x Migration**: Upgraded `hashicorp/azurerm` from `~> 3.62.1` to `~> 4.0`. Removed deprecated `prevent_deletion_if_contains_resources` blocks from provider configurations and updated storage accounts to enforce `min_tls_version = "TLS1_2"`.
- **Microsoft Entra ID (AzureAD) v3.x Migration**: Upgraded `hashicorp/azuread` from `~> 2.39.0` to `~> 3.0` for full Microsoft Graph API v1.0 compliance.
- **MongoDB Atlas Advanced Cluster Modernization**: Migrated all database clusters from deprecated `mongodbatlas_cluster` to `mongodbatlas_advanced_cluster` with `replication_specs`, `region_configs`, `electable_specs`, and continuous cloud backup.
- **Kubernetes Provider Upgrade**: Upgraded `hashicorp/kubernetes` from `~> 2.21.1` to `~> 2.32.0`.
- **Azure DevOps Pipeline Security Hardening**: 
  - Upgraded 29 pipeline runner configurations from deprecated `ubuntu-20.04` to `ubuntu-latest` (Ubuntu 24.04 LTS).
  - Eliminated plaintext `-var secret_...` CLI parameters in favor of masked `TF_VAR_` environment variables.
  - Added Workload Identity Federation (OIDC) support via `ARM_USE_OIDC: "true"`.
- **Media Asset Exclusion**: Excluded 1.4 GB of legacy binary media files (`videos/`, `audio/`, `slides/`, `infographic/`) to keep repository agile, lightweight (<20 MB), and focused on code.

## [1.8.13] - 2026-06-19

### Changed
- **Anonymization Notice Promoted to a Numbered Section**: Moved the "Network and Access Anonymization Notice" out of the document header into a dedicated, numbered **`## 3. Network and Access Anonymization Notice`** section placed right before *Document Inventory*, with a matching Table of Contents entry. Every subsequent section, subsection, TOC anchor, and in-body `Section X.Y` cross-reference was renumbered in cascade (old `3..15` → `4..16`).
- **Notice Readability**: Reformatted the notice so each VNet, subnet, and whitelist resource and its CIDR appears on its own nested bullet, instead of packing multiple CIDRs into single prose lines.

### Fixed
- **Broken Internal Anchors**: Fixed four pre-existing broken internal links in `README.md` by aligning their anchors and section numbers to the real target headings (the `2.1` Start-Here entry, `7.4` Global Environment and Subscription Matrix, `10.2` Master Ecosystem Inventory and Deployment Order, and `9.5.1` Cluster Autoscaler). All 108 internal anchor links now resolve.

## [1.8.12] - 2026-06-19

### Added
- **"Why These Ranges?" IPAM Rationale**: New section in `docs/141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md` explaining why each address block (RFC 1918 private space, RFC 5737 documentation ranges, RFC 1122 loopback, and `0.0.0.0/0`) is the standard, safe choice for published demos and Proof-of-Concept repositories, plus a new "How to Change the Values for a Real Deployment" section and an RFC 5737 reference in the validated library.

### Changed
- **Network IPAM Anonymization Scheme (Functional & Deployable)**: Replaced the non-functional `127.0.0.1/x` loopback placeholders — left over from a previous blanket anonymization pass — with a two-tier, **anonymized-but-deployable** addressing scheme modeled on the original architecture. Every Terraform manifest is now valid and `plan`-able as-is, while no value reveals or collides with a real production network.
    - **Private networks (RFC 1918, functional)**:
        - **Shared core VNet** for `App-Core`, `App-Catalog`, `Day2-ops`, and `Shared-Infra`: `10.10.0.0/24` (with `10.20.0.0/24` kept commented as the second-region/environment alternative). Workload subnets are `10.10.0.0/26` for App-Core and `10.10.0.0/27` for the other stacks.
        - **AKS VNet** `10.0.0.0/8`: API server subnet `10.1.0.0/28`, node subnet `10.0.32.0/19`, pod subnet `10.0.64.0/19`.
        - **AKS service plane**: `service_cidr = 10.0.0.0/19` (kept non-overlapping with the node/pod subnets, as Azure CNI requires) and `dns_service_ip = 10.0.0.10`.
    - **Public access points (non-routable placeholders)**:
        - AKS `authorized_ip_ranges` → `198.51.100.0/24` (RFC 5737 "TEST-NET-2" documentation range) and `0.0.0.0/32` — commented examples that must be replaced with real egress IPs before enabling public API access.
        - `mongodb_atlas_cidr_block` → `0.0.0.0/0` (intentionally open for the PoC; lock down for any non-demo use).
    - **Comment & illustration consistency**: Updated the `sipcalc` split-network comment blocks, the AKS "default network settings" notes, the example `# vpc_cidr` annotations, and the commented UDR `address_prefix` to match the new values, so every illustrative comment is internally consistent with the deployed defaults.
- **Anonymization Notice (README)**: Rewrote the root `README.md` "Network and Access Anonymization Notice" to accurately describe the implemented two-tier scheme, document that every value is a `variables.tf` default meant to be overridden via `.tfvars`, and explain why the chosen ranges are safe to publish.
- **141 IPAM Guide Reconciliation**: Reworked the strategy, IPAM reference matrix (now "Anonymized vs Recommended Values" with the real repo values), Golden Rule, subnetting logic, and authorized-IP sections of `docs/141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md` to match the implemented scheme instead of the previous loopback-obfuscation narrative.
- **Hostname Casing Consistency**: Standardized the DNS parent zone and Azure Container Registry hostnames to lowercase across all manifests, configuration files and documentation, aligning with DNS and container-registry naming conventions and removing casing inconsistencies between files.

### Fixed
- **Terraform PoC Manifest Integrity**: Restored malformed HCL blocks in the Cosmos DB PoC manifests (`App-Core/poc-cosmosdb-mongo/terraform-manifests/outputs.tf` and `variables.tf`). Two `output` blocks and two `variable` declarations had lost their header/value lines, which broke HCL parsing for that stack. The whole repository now parses cleanly with `terraform fmt`.
- **Documentation Link Accessibility**: Fixed broken relative links in `docs/111`, `docs/131`, and `docs/324` (an incorrect relative path to `.well-known/ai-context.md` and two references using outdated document numbering), restoring 100% link resolution across the docs.

## [1.8.11] - 2026-06-18

### Changed
- **Media Asset Normalization**: Renamed all 42 media files in `slides/`, `audio/`, and `videos/` to start with a double-digit sequential number prefix to ensure uniqueness and clean resource indexing.
- **Documentation Standards Alignment**: Removed the emoji from the Infographic Gallery header in the root `README.md` to enforce the pure-text header governance mandate.
- **Start Here Section Expansion**: Consolidated the four newly added PDF presentations into section 2.1, adding enriched text detailing their individual purposes, target audiences, and differences.
- **Link Quality Assurance**: Updated all internal and relative links across the repository's Markdown documents to reflect the normalized filenames, verifying 100% link accessibility.

## [1.8.10] - 2026-06-13

### Added
- **Master Architectural Summary**: Integrated a new comprehensive PDF presentation (`01_Master_Architectural_Summary_Azure_DevOps_Blueprint_2026.pdf`) generated by NotebookLM. This document serves as the primary technical overview of the entire Vision 2026 ecosystem, synthesizing all 49 architectural infographics into a single, high-fidelity summary.

## [1.8.9] - 2026-06-13

### Added
- **Global Infographic Expansion**: Integrated 7 additional high-fidelity blueprints from the `tmp15` inventory, reaching a total of 49 architectural visualizations:
    - **Azure DevOps Secure Infrastructure Governance and Permissions**: Deep-dive into RBAC and security boundaries.
    - **Cloud Secrets Vault Governance Playbook**: Advanced secret management strategies.
    - **App-Core Variable Management Engine**: Variable flow and transformation logic.
    - **The Vision 2026 Variable Engine**: Strategic variable architecture.
    - **Cloud Infrastructure Pipeline Lifecycle Blueprint**: End-to-end pipeline stages.
    - **Cloud Infrastructure Pipeline Logic**: Internal pipeline execution patterns.
    - **Infrastructure Orchestration Azure DevOps Pipeline Template Blueprint**: Reusable pipeline templates.

## [1.8.8] - 2026-06-12

### Added
- **Orchestration Flow Expansion**: Integrated a new high-fidelity blueprint from the `tmp14` inventory, reaching a total of 42 architectural visualizations:
    - **Global Configuration Pipeline Variable Flow**: A deep-dive into the deterministic flow of variables across global orchestration layers.

## [1.8.7] - 2026-06-12

### Added
- **Global Infographic Expansion**: Integrated 6 additional high-fidelity blueprints from the `tmp13` inventory, reaching a total of 41 architectural visualizations:
    - **Multi-Tenant Identity Governance Infographic (AE Title)**
    - **Managed AKS Cluster Certificate Bridge Workflow**
    - **Cloud Infrastructure Global Variable Architecture Vision**
    - **Strategic Architecture Roadmap Evolution**
    - **Enterprise Architecture AKS Modernization Roadmap**
    - **Database Roadmap Evolution and Architecture Shift (Cosmos DB)**
- **Extended Roadmap Gallery**: Reorganized the future evolution category to include the new domain-specific roadmaps for AKS and Database modernization.

## [1.8.6] - 2026-06-12

### Changed
- **IPAM Alignment**: Synchronized the "IPAM Reference Matrix" in `docs/141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md` with the "Representative Allocation Patterns" declared in the `README.md` header to ensure architectural consistency.
- **Topology Refinement**: Updated recommended production CIDRs (10.0.0.0/16, 10.1.0.0/16, 10.240.0.0/16) to reflect the Hub-and-Spoke and AKS networking standards of the blueprint.

## [1.8.5] - 2026-06-12

### Fixed
- **Documentation Standards**: Added missing bottom navigation bar to `docs/141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md` to comply with the project's Dual Navigation mandate.

### Changed
- **Header Integration**: Added a direct strategic link to the Architecture Adoption Guide from the "Network and Access Anonymization Notice" in the root `README.md`.

## [1.8.4] - 2026-06-12

### Added
- **Architecture Adoption and IPAM Guide**: Integrated a new strategic manual (`docs/141-ARCHITECTURE_ADOPTION_AND_IPAM_GUIDE.md`) to facilitate the de-obfuscation of the repository's network CIDRs.
- **De-Obfuscation Strategy**: Formally documented the "IPAM Reference Matrix" and the "Golden Rule" for variable injection via `.tfvars` to ensure safe real-world implementations.
- **Developer Utility**: Provided a safe find-and-replace command for reverting hardcoded UDR loopback placeholders to standard internet routes.

## [1.8.3] - 2026-06-12

### Changed
- **Roadmap Consolidation**: Reordered the infographic gallery to move the high-fidelity enterprise blueprint and the AI-assisted roadmap to the final "Future Roadmap and Evolution" category.
- **Sequential Renumbering**: Updated all 35 architectural blueprints to maintain a clean numerical sequence (1-35) following the structural correction.

## [1.8.2] - 2026-06-12

### Added
- **Expanded Infographic Collection**: Integrated 6 new high-fidelity blueprints from the `tmp12` inventory, reaching a total of 35 architectural visualizations:
    - **Vision 2026 Enterprise Infrastructure Blueprint (High-Fidelity)**
    - **Shared Infrastructure Ecosystem**
    - **Cloud Governance, RBAC and Subscriptions**
    - **Identity-Driven Infrastructure Automation (OAuth 2.0)**
    - **Infrastructure State Command Center (.tfstate Logic)**
    - **Infrastructure Automation Roadmap 2026 (AI-Assisted IaC)**

### Changed
- **Advanced Gallery Categorization**: Restructured the root `README.md` infographic gallery into 8 specialized strategic categories to improve architectural discoverability and accommodate the growing collection.
- **UI/UX Optimization**: Refined the gallery layout to eliminate formatting gaps between dropdowns and ensured sequential numbering across all 35 blueprints.

## [1.8.1] - 2026-06-11

### Added
- **Orchestration and Operations Blueprints**: Integrated two new high-fidelity infographics from the `tmp11` inventory:
    - **Blueprint 21**: Cloud Infrastructure Orchestration Engine (Azure DevOps Pipelines).
    - **Blueprint 22**: Post-Deployment Infrastructure Operations Hierarchy (Day 2 Ops).
- **Gallery Expansion**: Updated the categorized gallery to include these new deep-dives within the Infrastructure Pillars section, expanding the total collection to 29 blueprints.

## [1.8.0] - 2026-06-11

### Added
- **Global Infographic Gallery**: Integrated 13 additional high-fidelity infographics from the temporary inventory, expanding the collection to 27 architectural visualizations.
- **Categorized Visual Experience**: Reorganized the root `README.md` infographic section into four strategic clusters:
    - **Strategic Vision**: High-level blueprints and executive summaries.
    - **Infrastructure Pillars**: Low-level technical anatomy and deep-dives into Networking, Identity, and Compute.
    - **IaC Engine**: Variables orchestration, tfvars flow, and module composition strategies.
    - **Future Evolution**: Roadmap focusing on Terraform Stacks.
- **Master Gallery Toggle**: Implemented a "Show All" master dropdown to allow simultaneous viewing of all 27 blueprints, improving architectural assimilation.

## [1.7.7] - 2026-06-10

### Added
- **Infrastructure Evolution Blueprint**: Integrated a new high-fidelity infographic focusing on Terraform Stacks and Module Versioning strategies within the Vision 2026 framework.

## [1.7.6] - 2026-06-10

### Added
- **Module Orchestration Blueprints**: Integrated two new high-fidelity infographics comparing Composite vs. Atomic Terraform module strategies and orchestration architecture.

## [1.7.5] - 2026-06-10

### Security
- **Network Anonymization Notice**: Integrated a comprehensive security notice in the root `README.md` header, documenting the anonymization of CIDR ranges, VNet addresses, and access whitelists to protect architectural confidentiality.

## [1.7.4] - 2026-06-10

### Added
- **Detailed .tfvars Blueprints**: Integrated three new high-fidelity infographics focused on the Terraform variable engine and environment configuration flow.

### Changed
- **Performance Optimization**: Consolidated all infographics in `docs/213-TERRAFORM_ENVIRONMENT_CONFIGURATION_AND_TFVARS_INVENTORY.md` into an expandable dropdown to mitigate network latency and improve page load experience.
- **Documentation Scaling**: Expanded the root `README.md` blueprint collection to 11 distinct architectural visualizations.

## [1.7.3] - 2026-06-10

### Added
- **High-Fidelity Blueprints**: Integrated new architectural infographics from the Vision 2026 collection, including a Strategy Blueprint and a Spanish edition for broader accessibility.

### Changed
- **Documentation Layout**: Consolidated all architectural blueprints into an expandable dropdown section in the root `README.md` to enhance readability and prioritize technical content.

## [1.7.2] - 2026-06-09

### Changed
- **Global Asset Normalization**: Completed the removal of Spanish accents from all asset filenames (videos) to ensure universal compatibility across all operating systems and web browsers.

## [1.7.1] - 2026-06-09

### Changed
- **Asset Normalization**: Renamed newly integrated video assets to remove Spanish accents from filenames, ensuring better cross-platform compatibility and resolving potential URI encoding issues.

## [1.7.0] - 2026-06-09

### Added
- **High-Fidelity Architectural Blueprints**: Integrated a new series of high-resolution infographics covering high-level blueprints, low-level technical anatomy, and DevSecOps patterns, all accessible via a new collapsible gallery in the root `README.md`.
- **Domain-Specific Technical Assets**:
    - **App-Core and App-Catalog**: Added comprehensive video guides and technical blueprints (PDF) for the core application and service registry modules.
    - **DNS and Networking Deep-Dives**: Integrated new IaC video summaries and technical presentations focused on the decoupling of DNS infrastructure and module-specific orchestration.

## [1.6.0] - 2026-06-09

### Added
- **Hybrid Integration Assets**: Integrated new technical assets for the Integration Service, including a universal connector architecture blueprint (PDF) and video guides (MP4) in both English and Spanish, covering AppLink signaling and legacy connectivity patterns.

## [1.5.0] - 2026-06-09

### Added
- **Networking and DNS Technical Assets**: Integrated new NotebookLM-generated high-fidelity assets, including a dynamic infrastructure blueprint (PDF) and technical video summaries (MP4) in both English and Spanish, covering Hub-Spoke and DNS orchestration.

## [1.4.0] - 2026-06-08

### Added
- **GitFlow Development Model**: Added a high-fidelity visualization of the Azure DevOps GitFlow model (`azure-devops-gitflow-based-devel-model-shared-infra.png`) across Shared Infrastructure and AKS documentation tiers.

### Changed
- **App Service Observability**: Updated the App Service Log Stream screenshot (`log-stream-in-azure-app-service-debugconsole.png`) with an improved, correctly cropped version for better visual clarity.

## [1.3.0] - 2026-06-08

### Added
- **AI Usage Clarification**: Formally documented the distinction between the **human-crafted code base** (Terraform, YAML, scripts) and the **AI-enhanced documentation** (README, docs inventory, NotebookLM). This ensures transparency regarding technical provenance.

### Changed
- **Provenance Documentation**: Updated `docs/121-PROVENANCE_AND_LEGAL.md` and the root `README.md` to reflect the repository's "Human-Crafted" quality benchmark for core engineering logic.

## [1.2.0] - 2026-06-08

### Added
- **Repository Engineering Metrics (v2)**: Integrated advanced repository analytics into the root `README.md`, including a new dedicated column for `.tfvars` Data Orchestration files.
- **Enhanced Data Visualization**: Updated Mermaid distribution charts to reflect the growth of the codebase and the complexity of the environment configuration layer (535 total files).
- **Orchestration Layer Visibility**: Formally recognized the `.tfvars` configuration files as a core architectural pillar in the repository metrics.

### Changed
- **Metric Recalculation**: Updated global counts for `App-Core`, `Identity`, and `Day2 Ops` modules to include recent architectural expansions and documentation assets.

## [1.1.0] - 2026-06-08

### Added
- **NotebookLM Technical Assets**: Integrated high-fidelity AI-generated video summaries and technical slides to the core documentation.
- **Data Orchestration Infographic**: Added a new visual blueprint for environment configuration and `.tfvars` orchestration in `docs/213-TERRAFORM_ENVIRONMENT_CONFIGURATION_AND_TFVARS_INVENTORY.md`.
- **Categorized Learning Series**: Structured the `README.md` to include categorized technical deep-dives for Identity, MLOps, and Infrastructure Engine logic.

### Changed
- **Documentation Restructuring**: Reorganized the Strategic Presentations section in the root `README.md` for better discoverability and technical narrative.

## [1.0.1] - 2026-06-08 (Deprecated/Internal)
*(Merged into 1.1.0)*

---

## [1.0.0] - 2026-06-07

### Added
- **Enterprise IaC Baseline**: End-to-end infrastructure automation for Azure (AKS, App Service, Networking, Cosmos DB) using Terraform.
- **CI/CD Orchestration**: Standardized Azure DevOps pipelines for deployment, destruction, and state management across all modules.
- **Identity and Governance**: Implemented Entra ID integration, RBAC structures, and automated identity governance (Groups, Roles, CAP).
- **Environment Parity**: Automated configuration via anonymized `.tfvars` for consistent ENG (DEV/QA/UAT) and PRO environments.
- **Architectural Documentation**: Comprehensive "Vision 2026" guide including Mermaid diagrams and deep-dive technical manuals.

### Changed
- **Terminology Harmonization**: Unified product names, module identifiers, and container registry standards (`enterpriseappcr`).
- **Standardization**: Aligned all manifests and documentation with the Vision 2026 Architectural Guide.

### Fixed
- **UI/UX Optimization**: Implemented collapsible blocks for large-scale architectural diagrams to improve documentation readability.

### Security
- **Data Hardening**: Full anonymization of organizational identifiers, execution timestamps, and sensitive metadata across all assets.
- **Zero-Trust Architecture**: Enforced Managed Identities (MSI), OIDC Workload Identity, and compound identity trust patterns.
- **Infrastructure Security**: Integrated Azure RBAC for Key Vault/Storage access and enforced HTTPS/VNet-integration defaults.
