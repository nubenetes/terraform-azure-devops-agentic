[ Previous: 213. Configuration Inventory](213-TERRAFORM_ENVIRONMENT_CONFIGURATION_AND_TFVARS_INVENTORY.md) | [ Home](../README.md) | [ Next: 311. Hub-Spoke Backbone](311-SHARED_INFRA_NETWORKING_HUB_SPOKE_BACKBONE.md)

---

# 221. Visualizations

---

##  Table of Contents

- [1. Global Module Dependency Stack](#1-global-module-dependency-stack)
- [2. Internal Resource Dependency Graph (App-Core Example)](#2-internal-resource-dependency-graph-app-core-example)
- [3. Generating Graphs Manually](#3-generating-graphs-manually)
    - [3.1 Prerequisites](#31-prerequisites)
    - [3.2 Execution](#32-execution)
- [4. Architectural Insights: Dependency Types](#4-architectural-insights-dependency-types)
- [5. Validated Reference Library (Official and Community)](#5-validated-reference-library-official-and-community)

---

## 1. Global Module Dependency Stack

The following diagram illustrates the high-level orchestration order and data flow between the different infrastructure "Stacks" (Root Modules).

> **Architectural Note**: In production, each block below represents a sovereign Git repository within a **Federated Multi-Repo** setup. Dependencies are resolved via Data Sources or Pipeline artifacts rather than direct internal links.

<details>
<summary><b>📊 Click to expand Diagram: Global Module Dependency Stack</b></summary>

```mermaid
graph TD
    classDef foundation fill:#1f4e79,stroke:#fff,stroke-width:2px,color:#fff
    classDef platform fill:#5835CC,stroke:#fff,stroke-width:2px,color:#fff
    classDef workload fill:#548235,stroke:#fff,stroke-width:2px,color:#fff
    classDef data fill:#c55a11,stroke:#fff,stroke-width:2px,color:#fff
    classDef ops fill:#7b7b7b,stroke:#fff,stroke-width:2px,color:#fff
    subgraph Layer_1 [1. Foundational Backbone]
        SI["<b>Shared-Infra</b><br/>VNet, DNS, Firewall"]
    end
    subgraph Layer_2 [2. Identity and Compute]
        AKS["<b>AKS Cluster</b><br/>Control Plane, Nodes"]
        USR["<b>App-Users</b><br/>AAD Groups, Roles"]
    end
    subgraph Layer_3 [3. Application Workloads]
        CORE["<b>App-Core</b><br/>WAF, APIs, Storage"]
        CAT["<b>App-Catalog</b><br/>Service Registry"]
    end
    subgraph Layer_4 [4. Operational Day-2]
        D2["<b>Day2-Ops</b><br/>Monitoring, Ingress"]
    end
    %% Dependencies
    SI ==> AKS
    SI ==> CORE
    AKS ==> D2
    USR -.-> CORE
    CORE ==> CAT
    class SI foundation
    class AKS platform
    class USR data
    class CORE,CAT workload
    class D2 ops
```

</details>

## 2. Internal Resource Dependency Graph (App-Core Example)

This diagram visualizes how resources within a single module (App-Core) are programmatically linked. This is a representation of the implicit and explicit dependencies created via HCL referential linking.

<details>
<summary><b>📊 Click to expand Diagram: Internal Resource Dependency Graph (App-Core Example)</b></summary>

```mermaid
graph LR
    classDef logic fill:#fff2cc,stroke:#d6b656,stroke-width:1px,color:#333
    classDef azure fill:#dae8fc,stroke:#6c8ebf,stroke-width:1px,color:#333
    classDef security fill:#f4b183,stroke:#333,stroke-width:2px,color:#333
    subgraph Logic_Engine [Locals and Identity]
        L_ID["Instance Generator<br/>(locals.tf)"]
        A_REG["App Registration<br/>(Entra ID)"]
    end
    subgraph Networking [Network Fabric]
        RG["Resource Group"]
        VNET["VNet Hub-Spoke"]
        SNET["Subnets"]
        UDR["Route Tables<br/>(Forced Tunneling)"]
    end
    subgraph Compute [Runtime]
        ASP["App Service Plan"]
        APP_B["Backend API<br/>(Docker)"]
        APP_F["Frontend SPA<br/>(Static)"]
    end
    subgraph Data_Security [Security Silos]
        KV["Key Vault"]
        SA["Storage Account"]
        PE["Private Endpoints"]
    end
    %% Dependencies
    RG ==> VNET
    VNET ==> SNET
    SNET ==> UDR
    L_ID ==> A_REG
    A_REG ==> APP_B
    ASP ==> APP_B
    APP_B ==> KV
    APP_B ==> PE
    KV ==> PE
    SA ==> PE
    SNET -.-> PE
    class L_ID logic
    class A_REG,RG,VNET,SNET,UDR,ASP,APP_B,APP_F azure
    class KV,SA,PE security
```

</details>

## 3. Generating Graphs Manually

To generate a real-time dependency graph from the current state of any module, you can use the built-in Terraform command combined with Graphviz (`dot`).

### 3.1 Prerequisites

### 3.2 Execution
1. Navigate to the module directory (e.g., `Shared-Infra/terraform-manifests/`).
2. Initialize the module: `terraform init`.
3. Run the graph command:
```bash
terraform graph | dot -Tpng > architecture_dependency_graph.png
```

## 4. Architectural Insights: Dependency Types

| Dependency Type | Implementation in Code | Architectural Impact |
| :--- | :--- | :--- |
| **Implicit** | `subnet_id = azurerm_subnet.main.id` | Terraform automatically calculates the correct creation order. |
| **Explicit** | `depends_on = [azurerm_key_vault.main]` | Used for cross-provider dependencies (e.g., Helm waiting for AKS). |
| **Data-Driven** | `data.azurerm_vnet.hub.id` | Allows decoupling of "Stacks" (Shared-Infra vs App-Core). |
| **Identity-Driven** | `principal_id = azurerm_user_assigned_identity.main.id` | Core of the Zero-Trust security model. |

---

## 5. Validated Reference Library (Official and Community)

- **[HashiCorp: Terraform Graph Command Reference](https://developer.hashicorp.com/terraform/cli/commands/graph)**
- **[Pluralith: Automated Terraform Infrastructure Diagrams](https://www.pluralith.com/)**
- **[Rover: Interactive Terraform Visualizer](https://github.com/im2nguyen/rover)**
- **[Inframap: Read Terraform State and Draw a Graph](https://github.com/cycloidio/inframap)**
- **[Mermaid.js: Diagramming and Charting Tool](https://mermaid.js.org/)**
- **[Graphviz: Open Source Graph Visualization Software](https://graphviz.org/)**

---

[ Previous: 213. Configuration Inventory](213-TERRAFORM_ENVIRONMENT_CONFIGURATION_AND_TFVARS_INVENTORY.md) | [ Home](../README.md) | [ Next: 311. Hub-Spoke Backbone](311-SHARED_INFRA_NETWORKING_HUB_SPOKE_BACKBONE.md)

---

*Technical Documentation: Terraform Visualizations and Dependency Graphs | Vision 2026 Architectural Guide*