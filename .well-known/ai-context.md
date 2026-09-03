# 🤖 AI-Agent Engineering Rules (.well-known/ai-context)

> *This file provides rapid semantic context for AI coding agents (GitHub Copilot, Cursor, Gemini, GPT-4).*

## 🎯 Global Architecture Pattern
- **Project Structure**: Consolidated Monorepo with a Hub-Spoke network topology.
- **Compute Split**: Business containers in **Azure App Service**, Machine Learning in **AKS**.
- **Network Rule**: 100% Private Link enforced. 0 public inbound ports.
- **Identity Rule**: Use Workload Identity (OIDC) exclusively. No static secrets.

## 🛠 Coding Standards (The DRY Logic Engine)
1. **Intelligence Hub**: All complex values (Naming, IP Math, Tags) must reside in `locals.tf`.
2. **Naming Rule**: 
   - **Engineering**: Must use the `d` prefix (e.g., `stdnedev`, `rg-dnedev`).
   - **Production**: No prefix (e.g., `stnepro`).
3. **Module Sourcing**: Use **Relative Paths** (`source = "../modules/..."`). Do NOT use Git Tags.
4. **Hybrid Signaling**: Refer to the **AppLink** pattern for all cloud-to-onprem connectivity.

## 💾 State Governance
- Storage Account: `sttfstateenterprisepro`.
- Partitioning: Per-module isolation (e.g., `sharedinfra-mainbranch-pro.tfstate`).
- Access: Private Link + Lease Locking.

## 🏁 Operational Commands
- Use the standard `terraform-plan.yml` templates for validation.
- All automation scripts are in the `DevSecOps Scripts Inventory` within the README.
