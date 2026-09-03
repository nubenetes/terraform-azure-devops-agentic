# Gemini Instructions: Enterprise Cloud Infrastructure (v2.0)

This document provides project-specific guidance for Gemini CLI to ensure consistent architecture, naming conventions, & 2026-standard compliance.

## 🏛️ Core Mandates

1.  **Zero-Trust Security**: Prioritize Managed Identities (MSI) & OIDC Workload Identity. Avoid long-lived secrets.
2.  **IaC Sovereignty**: All infrastructure MUST be defined via Terraform. No manual changes via CLI or Portal.
3.  **Environment Isolation**: Maintain strict separation between Engineering (ENG) & Production (PRO).
4.  **Documentation Fidelity**: New architectural components MUST include high-fidelity Mermaid diagrams & deep-dive technical analysis as seen in the core manuals: `docs/111-ARCHITECTURE_2026.md` (Strategy), `docs/211-TERRAFORM_MODULE_DESIGN_PATTERNS.md` (Engineering), `docs/212-TERRAFORM_VARIABLE_ARCHITECTURE_AND_DATA_STRATEGY.md` (IaC Engine), `docs/221-TERRAFORM_VISUALIZATIONS_AND_DEPENDENCY_GRAPHS.md` (Graphs), `docs/311-SHARED_INFRA_NETWORKING_HUB_SPOKE_BACKBONE.md` (Networking), `docs/313-APP_GATEWAY_DEEP_DIVE.md` (L7 Traffic), `docs/322-ENTRA_ID_IDENTITY_GOVERNANCE_AUTOMATION.md` (Identity), `docs/323-KEY_VAULT_TRUST_ARCHITECTURE.md` (Secrets), `docs/331-AKS_COMPUTE_HUB_AND_ML_ORCHESTRATION.md` (Compute), `docs/341-DATABASE_ARCHITECTURE_AND_PERSISTENCE_STRATEGY.md` (Data), `docs/342-STORAGE_GOVERNANCE_AND_LIFECYCLE.md` (Governance), `docs/411-AZURE_DEVOPS_PIPELINES_ORCHESTRATION.md` (CI/CD), `docs/412-AZURE_DEVOPS_PIPELINE_SECURITY_AND_GOVERNANCE.md` (Pipeline Security), `docs/421-OBSERVABILITY_AND_DAY2_OPERATIONS.md` (Ops), & `docs/911-TROUBLESHOOTING_AND_OPERATIONAL_RUNBOOKS.md` (SRE).

## 🌿 Branching & Environment Mapping

| Branch | Environment Tier | Resource Prefix | Environments |
| :--- | :--- | :--- | :--- |
| `develop` | Engineering | **`d`** (e.g., `dst...`) | DEV, QA, UAT, PRE |
| `main` | Production | *None* (e.g., `st...`) | PRO, DEM |

- **Naming Convention**: `[Prefix]-[Region]-[Env]` (e.g., `rg-dnedev`, `rg-nepro`).
- **Region Codes**: `ne` (North Europe), `cus` (Central US).

## 🛠️ Terraform Standards (September 2026 Agentic Blueprint)

- **Terraform Core**: Target `>= 1.9.0, < 2.0.0` (1.10+ / 1.15+), using declarative `check`, `import`, and `removed` blocks.
- **Providers**: AzureRM `~> 4.0`, AzureAD `~> 3.0`, MongoDB Atlas `~> 1.25.0` (`mongodbatlas_advanced_cluster`), Kubernetes `~> 2.32.0`.
- **Identity**: Use `ARM_USE_OIDC = true` in pipelines and Workload Identity Federation for secretless operations.
- **Access Control**: Prefer **Azure RBAC** over Access Policies for new Key Vaults & Storage Accounts.
- **Trust Pattern**: Implement **Compound Identity (App-plus-User)** for multi-tenant secret access via `application_id` + `object_id` in access policies.
- **Storage**: Enforce `min_tls_version = "TLS1_2"` (AzureRM v4) & `public_network_access_enabled = true` (unless VNet-integrated).
- **Data Protection**: Ensure all File Shares are registered in a `azurerm_recovery_services_vault` with a valid `azurerm_backup_policy_file_share`.
- **Database**: Use `mongodbatlas_advanced_cluster` exclusively; `mongodbatlas_cluster` is deprecated.

## 🔄 Deployment Sequence

1.  **Shared-Infra**: Network Backbone (VNet, DNS, Peering).
2.  **App-Users**: Identity Governance (Groups, Roles, CAP).
3.  **App-Catalog**: Service Registry (Web App + DB).
4.  **App-Core**: Web Apps & Traffic Orchestration (WAF).
5.  **AKS Cluster**: Compute Hub & Nodepools.
6.  **Day2 Ops**: Observability & Ingress.

## 🤖 AI Workflow (Gemini)

- **Surgical Edits**: Use targeted `replace` for large manifests.
- **Verification**: Always check for `locals.tf` & `variables.tf` before hardcoding values.
- **Deep-Dive Logic**: When asked for architectural analysis, perform reverse engineering of `.tf` files to identify:
    - Identity Trust Models (RBAC vs. Access Policies).
    - Resource inter-dependencies (Managed Identities, Role Assignments).
    - Multi-tenant isolation patterns (`for_each` loops, dynamic container naming).
- **Commit Strategy**: Track `GEMINI.md` in the `develop` branch to maintain context across sessions.

## 📝 Documentation Governance (Vision 2026)

All architectural documents in the `docs/` directory & the root `README.md` MUST adhere to the following structural & stylistic standards:

1.  **Title & Versioning**:
    - Main titles (`#`) must be clear & professional.
    - **Prohibited**: Do NOT include version numbers (e.g., v2.0, v2.2) or dates in the title or headers.
2.  **Navigation Framework**:
    - Every document must include a consistent **Header** & **Footer** navigation bar:
      `[⬅️ Previous: title](file.md) | [🏠 Home](../README.md) | [➡️ Next: title](file.md)`
3.  **Table of Contents (TOC)**:
    - Section Header: `## 📑 Table of Contents`
    - Format: Exhaustive, nested bullet points (e.g., `- [Title](#anchor)`).
    - **Constraint**: Do NOT use internal numbering within TOC items; the hierarchy is indicated by indentation.
    - **Pure Text Mandate**: TOC labels MUST be pure text. No emojis or ampersands (`&`) are allowed.
4.  **Hierarchical Numbering**:
    - All headers MUST follow a strict numerical hierarchy: `## X.`, `### X.Y`, `#### X.Y.Z`.
    - **Prohibited**: Emojis and ampersands (`&`) are strictly forbidden in all headers. Use the word "and" instead.
5.  **Validated Reference Library**:
    - Every document MUST conclude with a standardized section:
      `## 📚 Validated Reference Library (Official & Community)`
    - Content: High-quality, validated links from official Microsoft Learn, HashiCorp, or industry standards (CNCF, OWASP).
6.  **Descriptive Footers**:
    - Footer text must be descriptive & atemporal.
    - **Prohibited**: "Last Updated", "Last Refined", or specific edit dates.
    - **Standard**: `*Technical Documentation: [Doc Title] | Vision 2026 Architectural Guide*`.
7.  **Structural Separation**:
    - Use horizontal rules (`---`) to separate major structural blocks (Nav-to-Title, Title-to-TOC, TOC-to-Content, Content-to-References).
8.  **Language**:
    - All structural elements (TOC, Nav, Headers, References) MUST be in **English**.
- **Link & Anchor Integrity**:
    - Every structural change (renumbering headers, adding/removing sections) MUST be followed by a comprehensive audit of internal anchors & cross-document links.
    - **Special Characters**: GitHub slugification often converts characters like `&` into hyphens (resulting in `--` if surrounded by spaces) & handles emojis as prefix hyphens. Always verify that TOC anchors match the GitHub-rendered ID (e.g., `#section--title` for `Section & Title`).
    - **Verification**: Use `grep_search` to identify all files referencing the modified document & verify that anchor IDs (e.g., `#11-title`) remain valid.

    9.  **README.md Synchronization**: Ensure the root `README.md` & the `Doc Inventory` tables are updated if document titles or primary section numbers change.
    10. **Language Sovereignty**: All documentation (README.md, docs/*.md, & code comments) MUST be written in **English** to maintain professional consistency & global accessibility. If existing content is in another language, it must be translated to English without loss of technical fidelity.
    11. **Scalable Tiered Centenas Model**: All files in `docs/` MUST follow a 3-digit semantic numbering system:
        - **100 - Foundations & Strategy**: (110: Vision, 120: Legal, 130: Platform).
        - **200 - IaC Engineering & Patterns**: (210: Terraform Architecture, 220: Visualization).
        - **300 - Infrastructure Pillars**: (310: Networking, 320: Identity/Security, 330: Compute, 340: Data).
        - **400 - DevSecOps & Operations**: (410: Orchestration/Security, 420: Day 2 Ops).
        - **800 - Analytical & Governance (GRC)**: (810: Resilience, 820: Economics).
        - **900 - Reference & Closure**: (910: SRE/Runbooks, 990: Roadmap/Backlog).
        - **Rule**: Hundreds = Primary Category, Tens = Sub-Category, Ones = Document Sequence. Leave gaps between sub-categories to allow for organic growth.
    12. **Self-Learning & Adaptive Correction**: The agent MUST treat every user correction regarding documentation style, rendering, or structure as a "High-Priority Learning Event".
        - **Protocol**: Before applying a fix, analyze WHY the error occurred & update internal strategy to prevent it across ALL documents, not just the one reported.
        - **Memory**: Consolidate these learnings into the `MEMORY.md` file if they are project-specific, or apply them as foundational logic.
    13. **Universal Documentation Checklist**: **EVERY** markdown file update (including `README.md`, `docs/*.md`, and any newly generated documents) MUST pass the following validation sweep:
        - [ ] **Dual Navigation**: For sequential docs, navigation bars (Prev | Home | Next) MUST exist at BOTH the Top and Bottom. For the root `README.md`, a single top-level navigation to core sections is sufficient.
        - [ ] **Reference Sovereignty**: All external links and official documentation MUST be consolidated within the `## 📚 Validated Reference Library` section at the end of the file. No dangling lists of links are allowed in the body.
        - [ ] **Mermaid Block Integrity**: ````mermaid` blocks MUST NOT contain any blank lines. Technical statements (nodes, arrows, labels) MUST be atomic, syntactically complete, and stay on the same line to prevent rendering failures. Relationship operators (`-->`, `==>`, `-.->`, etc.) MUST always exist between nodes and must not be separated from them by newlines. The use of the `and` operator to combine multiple relationships in a single line is strictly prohibited for cross-platform compatibility.
        - [ ] **Flowchart Relationship Integrity**: In `graph` or `flowchart` blocks, every relationship MUST be atomic (one source, one destination). Chaining multiple destination nodes with `&` or `and` is strictly prohibited. For example, `A --> B & C` MUST be split into `A --> B` and `A --> C` on separate lines.
        - [ ] **Sequence Diagram Integrity**: `sequenceDiagram` blocks MUST follow strict syntax for actor interactions. Every interaction MUST include both a source and a destination actor (e.g., `Actor->>Actor: Message`). Implicit "self-messaging" or standalone commands (e.g., `->Message`) are strictly prohibited as they cause rendering failures in many environments.
        - [ ] **Pure Text Headers and TOC**: Verify that NO emojis or ampersands (`&`) exist in any header or TOC label. All `&` must be replaced by "and".
        - [ ] **Table Fidelity**: Markdown tables MUST be preceded by a blank line and use standard alignment separators (`| :--- |`, `| :---: |`, or `| ---: |`). Syntax like `::` is strictly prohibited. Every row MUST be on its own line; collapsed rows are forbidden.
        - [ ] **Structural Integrity**: Ensure no duplicated headers, correct TOC anchors, and adherence to the hierarchical numbering standard.
        - [ ] **GitHub Anchor Integrity**: TOC anchors MUST follow GitHub's slugification logic:
            - **Lowercase**: All characters must be lowercased.
            - **Remove Punctuation**: Remove dots, colons, and parentheses.
            - **Hyphen Mapping**: Spaces MUST map to hyphens (`-`).
            - **Example**: `## 7. Deep-Dive: Networking and Security` maps to `[Deep-Dive](#7-deep-dive-networking-and-security)`.


