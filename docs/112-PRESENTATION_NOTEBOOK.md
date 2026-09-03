[ Previous: 111. Architecture Strategy](111-ARCHITECTURE_2026.md) | [ Home](../README.md) | [ Next: 121. Provenance and Legal](121-PROVENANCE_AND_LEGAL.md)

---

# 112. Presentation Notebook

---

##  Table of Contents

- [1. Project: Terraform Azure DevOps Examples (Vision 2026)](#1-project-terraform-azure-devops-examples-vision-2026)
    - [1.1 Strategic Core](#11-strategic-core)
    - [1.2 Architecture Map (Hub-Spoke and Edge)](#12-architecture-map-hub-spoke-and-edge)
        - [1.2.1 A. Shared-Infra (The Hub)](#121-a-shared-infra-the-hub)
        - [1.2.2 B. AKS and App-Core (The Spokes)](#122-b-aks-and-app-core-the-spokes)
    - [1.3 Automation: The DevOps "Engine"](#13-automation-the-devops-engine)
    - [1.4 Security Posture: Zero Trust Edge](#14-security-posture-zero-trust-edge)
    - [1.5 Provenance and Technical Foundations](#15-provenance-and-technical-foundations)
    - [1.6 Vision 2026: Evolution Roadmap](#16-vision-2026-evolution-roadmap)
- [2. Validated Reference Library (Official and Community)](#2-validated-reference-library-official-and-community)

---

## 1. Project: Terraform Azure DevOps Examples (Vision 2026)

This Notebook synthesizes the technical and strategic intelligence embedded in this repository. It is designed to provide architects and SRE teams with an immediate understanding of the automation ecosystem.

### 1.1 Strategic Core
This repository is not just a collection of scripts; it is a **reference implementation** for scalable architectures on Azure.

*   **Philosophy:** "Everything as Code" (EaC). From the WAF to Azure AD user management.
*   **Operating Model:** GitOps based on GitFlow. Each branch (`main`, `develop`) manages its own Terraform state, allowing for isolated experimentation.
*   **Compliance:** Aligned with the **Microsoft Cloud Adoption Framework (CAF)** and the **Well-Architected Framework (WAF)**.

### 1.2 Architecture Map (Hub-Spoke and Edge)

The ecosystem is divided into layers of clear responsibility:

#### 1.2.1 A. Shared-Infra (The Hub)
*   **Purpose:** Common services and connectivity.
*   **Components:** Central VNet, Private DNS, corporate Key Vaults, and a unified Log Analytics Workspace.
*   **Reference:** [`Shared-Infra/terraform-manifests/`](../Shared-Infra/terraform-manifests/)

#### 1.2.2 B. AKS and App-Core (The Spokes)
*   **AKS Masterclass:** A hardened production cluster with support for Linux/Windows nodes, automatic scaling, and integrated RBAC security.
*   **App-Core:** The heart of the platform. Includes Application Gateway v2 with WAF, isolated App Services, and managed databases.
*   **Reference:** [`AKS/`](../AKS/) | [`App-Core/`](../App-Core/)

### 1.3 Automation: The DevOps "Engine"

The crown jewel is the deployment engine based on **Azure DevOps YAML Multi-stage Pipelines**.

| Pipeline | Function | Innovation |
| :--- | :--- | :--- |
| **Provisioning** | IaC with Terraform | Use of reusable `templates` and locked state management. |
| **K8s Deploy** | Helm and Manifests | Application deployment on AKS with pod health validation. |
| **State Management** | Day 2 Operations | Dedicated pipelines for `state-rm`, `force-unlock`, and resource import. |

### 1.4 Security Posture: Zero Trust Edge

Following the **WAF 2026 Strategy**, security moves to the **Edge**:

1.  **Defense in Depth:** Integration of Azure Front Door (Global) + Application Gateway (Regional).
2.  **Intelligent Protection:** Use of *Bot Manager* and *Default Rule Set 2.1* (AI) to mitigate attacks before they touch the internal network.
3.  **Total Isolation:** Transition towards **Private Links** so that no internal component has a public IP.
4.  **Reference:** [`314-AZURE_WAF_IMPROVEMENTS.md`](./314-AZURE_WAF_IMPROVEMENTS.md)

### 1.5 Provenance and Technical Foundations

The code has a clear and professional genealogy, based on authoritative sources:

*   **Foundational Knowledge:** Based on the course by **Kalyan Reddy Daida (StackSimplify)**, adapted and hardened for real corporate environments.
*   **Architectural Influences:** John Savill (Networking), Sam Cogan (Multi-subscription), Chris Pietschmann (Feature Flags).
*   **Legal Reference:** [`121-PROVENANCE_AND_LEGAL.md`](./121-PROVENANCE_AND_LEGAL.md) (Includes liability disclaimer and intellectual property protection).

### 1.6 Vision 2026: Evolution Roadmap

1.  **vWAN Transformation:** Migration from traditional Hub-Spoke to Virtual WAN for global scale.
2.  **AI-Ops Integration:** Advanced telemetry in Sentinel for automatic incident response.
3.  **Serverless K8s:** Massive adoption of *Virtual Nodes* for cost optimization (FinOps).

---

## 2. Validated Reference Library (Official and Community)

- **[Microsoft Cloud Adoption Framework (CAF) for Azure](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)**
- **[Microsoft Azure Well-Architected Framework (WAF)](https://learn.microsoft.com/en-us/azure/well-architected/)**
- **[StackSimplify: Terraform on Azure DevOps Course](https://stacksimplify.com/)**
- **[John Savill's Technical Training: Azure Networking Deep Dive](https://www.youtube.com/@ntfaqguy)**
- **[Azure Architecture Center: Hub-Spoke Topology](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)**
- **[HashiCorp: Terraform Best Practices for Enterprise](https://www.hashicorp.com/resources/terraform-best-practices-for-enterprise)**

---

[ Previous: 111. Architecture Strategy](111-ARCHITECTURE_2026.md) | [ Home](../README.md) | [ Next: 121. Provenance and Legal](121-PROVENANCE_AND_LEGAL.md)

---

*Technical Documentation: Notebook LLM: Enterprise Cloud-Native Reference Architecture | Vision 2026 Architectural Guide*