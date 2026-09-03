[ Previous: 131. Internal Developer Platform](131-INTERNAL_DEVELOPER_PLATFORM.md) | [ Home](../README.md) | [ Next: 211. Module Design Patterns](211-TERRAFORM_MODULE_DESIGN_PATTERNS.md)

---

# 141. Architecture Adoption and IPAM Guide

---

## 📑 Table of Contents

- [1. Strategy 2026: Adapting the Blueprint for Real-World Deployments](#1-strategy-2026-adapting-the-blueprint-for-real-world-deployments)
- [2. Why These Ranges? Standard Address Blocks for Demos and PoCs](#2-why-these-ranges-standard-address-blocks-for-demos-and-pocs)
- [3. IPAM Reference Matrix: Anonymized vs Recommended Values](#3-ipam-reference-matrix-anonymized-vs-recommended-values)
- [4. The Golden Rule of Terraform Variables and tfvars](#4-the-golden-rule-of-terraform-variables-and-tfvars)
- [5. Subnetting Logic and cidrsubnet Math](#5-subnetting-logic-and-cidrsubnet-math)
- [6. How to Change the Values for a Real Deployment](#6-how-to-change-the-values-for-a-real-deployment)
- [7. Public Network Access and Authorized IP Ranges](#7-public-network-access-and-authorized-ip-ranges)
- [8. Validated Reference Library (Official and Community)](#8-validated-reference-library-official-and-community)

---

## 1. Strategy 2026: Adapting the Blueprint for Real-World Deployments

This repository follows an **"anonymized but deployable"** approach. Rather than scrubbing network values into broken placeholders, every CIDR is set to a range that is **reserved by a standard for documentation, demos, and PoCs** (see [Section 2](#2-why-these-ranges-standard-address-blocks-for-demos-and-pocs)). This protects architectural confidentiality — none of the values reveal or collide with the real production network — while every Terraform manifest stays **valid and plan-able as-is**.

Two tiers of anonymization are applied:

1.  **Private network ranges (RFC 1918)** — used for VNets, subnets, and the AKS service plane. These are not secrets (private IPs never route on the Internet), so they are kept as realistic, functional `10.x` values that mirror the original topology.
2.  **Public access points (RFC 5737 / loopback / `0.0.0.0`)** — used for AKS `authorized_ip_ranges` and database whitelists. These point to non-routable documentation ranges so that no real management endpoint is ever exposed in a published repo.

To run this blueprint against your own environment, you do **not** "de-obfuscate" anything by hand — you override the `variables.tf` defaults with your real IPAM plan through a `.tfvars` file ([Section 6](#6-how-to-change-the-values-for-a-real-deployment)).

## 2. Why These Ranges? Standard Address Blocks for Demos and PoCs

The chosen ranges are not arbitrary. Each is reserved by an RFC or cloud-vendor convention precisely so it can be published safely:

| Block | Reserved by | Why it is ideal for a demo/PoC |
| :--- | :--- | :--- |
| `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` | **RFC 1918** (private) | Non-routable on the public Internet; the de-facto standard for Azure VNets. `10.0.0.0/8` is the conventional choice for hub-and-spoke designs, so the topology reads as realistic without exposing the production plan. |
| `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` | **RFC 5737** (documentation) | Guaranteed to **never** route anywhere. Perfect stand-ins for *public* IPs (egress points, admin whitelists) in published docs — they look like real public addresses but can never reach a live host. |
| `127.0.0.0/8` | **RFC 1122** (loopback) | Never leaves the local host; a safe placeholder where a value must exist but must not point at anything reachable. |
| `0.0.0.0/0` and `0.0.0.0/32` | **"any" / unspecified** | `0.0.0.0/0` is the standard default route / "allow any"; `0.0.0.0/32` is the documented stub Azure requires in `authorized_ip_ranges` when public access is enabled. |

## 3. IPAM Reference Matrix: Anonymized vs Recommended Values

The table maps the anonymized values shipped in this repository to a representative production IPAM plan. The anonymized values are the **defaults** in each stack's `variables.tf` (or the hardcoded module values for AKS); the production column is one sensible target you would inject via `.tfvars`.

| Component | Anonymized Value (Repo) | Example Production Value | Rationale |
| :--- | :--- | :--- | :--- |
| **Shared core VNet** (App-Core, App-Catalog, Day2-ops, Shared-Infra) | `10.10.0.0/24` (alt `10.20.0.0/24`) | `10.1.0.0/16` (prod spoke) | Single shared spoke for app, ops, and shared services; size up to a `/16` for real growth. |
| **App-Core workload subnet** | `10.10.0.0/26` | `10.1.1.0/24` | Frontend / App Gateway / App Service. |
| **Other stack subnets** (Catalog, Day2-ops, Shared-Infra) | `10.10.0.0/27` | `10.1.x.0/27` | Small per-service subnets carved from the spoke. |
| **AKS VNet** | `10.0.0.0/8` | `10.240.0.0/16` | Large space for Azure CNI node + pod scaling. |
| **AKS API server subnet** | `10.1.0.0/28` | `10.240.0.0/28` | Minimum `/28` for API Server VNet Integration. |
| **AKS node subnet** | `10.0.32.0/19` | `10.240.32.0/19` | `/19` = 8,192 addresses to absorb high-churn rolling updates. |
| **AKS pod subnet** | `10.0.64.0/19` | `10.240.64.0/19` | Dynamic IP allocation for pods (Azure CNI). |
| **AKS `service_cidr`** | `10.0.0.0/19` | `10.244.0.0/19` | Kubernetes service range — must **not** overlap node/pod subnets. |
| **AKS `dns_service_ip`** | `10.0.0.10` | within `service_cidr` | CoreDNS service IP; must sit inside `service_cidr`. |
| **AKS `authorized_ip_ranges`** | `198.51.100.0/24`, `0.0.0.0/32` | your egress IPs | RFC 5737 placeholder — replace with real admin/CI IPs. |
| **MongoDB Atlas whitelist** | `0.0.0.0/0` | your egress CIDR | Open for the PoC; lock down for any real use. |
| **Default Internet Route (UDR)** | `0.0.0.0/0` | `0.0.0.0/0` | Standard next-hop Internet/Firewall route. |

## 4. The Golden Rule of Terraform Variables and tfvars

To keep the modular architecture intact while adapting it to your organization, follow the **Golden Rule of Variable Orchestration**:

1.  **Treat the defaults as safe demo values**: The `default` values in `variables.tf` are anonymized, plan-able ranges. They let you `terraform plan` immediately, but they are **not** meant for a shared production network — override them.
2.  **Externalize configuration**: Always use environment-specific `.tfvars` files (e.g., `prod-cus.tfvars`, `eng-developbranch.tfvars`) to inject your real CIDR ranges.
3.  **Variable precedence**: Terraform automatically prioritizes values from `.tfvars` over the defaults in the module manifests.

## 5. Subnetting Logic and cidrsubnet Math

This repository relies on consistent subnetting ratios. When choosing a new `address_space` for a VNet, ensure that your subnets maintain the required bit-masks for scaling.

*   **AKS Scaling**: A `/19` mask is used for the AKS node and pod subnets to prevent IP exhaustion during high-churn rolling updates and Pod scaling.
*   **Non-overlap rule**: The AKS `service_cidr` (`10.0.0.0/19`) is kept distinct from the node (`10.0.32.0/19`) and pod (`10.0.64.0/19`) subnets — Azure CNI rejects an overlapping service range.
*   **Logical Calculation**: Use the `cidrsubnet(prefix, newbits, netnum)` function in your `locals.tf` to programmatically derive subnets from a root VNet CIDR, ensuring no overlaps and easier refactoring.

## 6. How to Change the Values for a Real Deployment

You override the anonymized defaults; you never edit them in place. The mechanics differ slightly per tier:

**Private VNet / subnet ranges** are exposed as variables — set them in your `.tfvars`:

```hcl
# prod-cus.tfvars
vnet_cidr   = "10.1.0.0/16"
subnet_cidr = "10.1.1.0/24"
```

**AKS network ranges** (`address_space`, node/pod subnets, `service_cidr`, `dns_service_ip`) are currently hardcoded in `AKS/terraform-manifests/modules/sharedinfra_aks_module/15-virtual-network.tf` and `06-aks-cluster.tf`. Edit those module values directly (or promote them to variables) to match your `10.x` plan, keeping `service_cidr` non-overlapping with the node/pod subnets.

**Access whitelists** are the security-critical change — see [Section 7](#7-public-network-access-and-authorized-ip-ranges).

*Note: Always verify the changes with `terraform plan` and `git diff` before applying.*

## 7. Public Network Access and Authorized IP Ranges

For security-hardened clusters, the AKS API Server uses **Authorized IP Ranges**.

*   **Repo Placeholder**: The code uses `198.51.100.0/24` (RFC 5737 documentation range) and `0.0.0.0/32` as commented placeholders — neither can reach a real host.
*   **Adoption Step**: You **must** replace these with your organization's public egress IPs (VPN, Office, or CI/CD runner IPs) so that the Terraform pipeline or administrative consoles can interact with the Kubernetes API.
*   **MongoDB Atlas**: `mongodb_atlas_cidr_block` defaults to `0.0.0.0/0` (open) for the PoC. Restrict it to your real egress CIDR for any non-demo deployment.
*   **Hardening**: Ensure `public_network_access_enabled = true` is only used once you have correctly configured these authorized ranges.

## 8. Validated Reference Library (Official and Community)

*   **[Azure IPAM Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-ip-addressing)**: Official Microsoft guide for planning IP addressing.
*   **[Terraform cidrsubnet Function](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet)**: Documentation for programmatic subnetting.
*   **[RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918)**: Address Allocation for Private Internets.
*   **[RFC 5737](https://datatracker.ietf.org/doc/html/rfc5737)**: IPv4 Address Blocks Reserved for Documentation.

---

[ Previous: 131. Internal Developer Platform](131-INTERNAL_DEVELOPER_PLATFORM.md) | [ Home](../README.md) | [ Next: 211. Module Design Patterns](211-TERRAFORM_MODULE_DESIGN_PATTERNS.md)

---

*Technical Documentation: Architecture Adoption and IPAM Guide | Vision 2026 Architectural Guide*

---
