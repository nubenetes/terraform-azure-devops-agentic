# Table of Contents

1. [Enterprise Day-2 Operations Automation and Self-Service](#enterprise-day-2-operations-automation-and-self-service)
   1. [Kubernetes Day Zero](#kubernetes-day-zero)
   2. [Kubernetes Day One](#kubernetes-day-one)
   3. [Kubernetes Day Two](#kubernetes-day-two)
2. [Environments](#environments)
   1. [Matrix table](#matrix-table)
   2. [Matrix table with Azure DevOps Service Connections](#matrix-table)
3. [Requirements](#requirements)
4. [References](#references)

## Enterprise Day-2 Operations Automation and Self-Service

This repo contains GitOps pipelines involving Day-2 Operations. They are run after deploying AKS Clusters with ["shared-infra" pipelines](https://dev.azure.com/EnterpriseDev/Shared-Infra).

### Kubernetes Day Zero

Kubernetes Day Zero consists of:

- Proper communication
- Proper access
- Architecture
- Security protocols
- RBAC
- Best practices
- Tools list

Proper communication and proper access is more of a soft skill that a technical. You want to ensure that you know who to talk to from each team and what access you need to which environments.

Architecture is all about ensuring that you know how the kubernetes environment will look before you start building it.

Security protocols and RBAC in Day Zero is all about planning. Not implementing, just plannning. Figure out how security for your environment will look and what is needed.

Best practices are all about figuring out what's suitable for your environment. For example, a best practice for you may be to ensure that clusters are built with Terraform. For other orgs, it may be a different tool.

The tools and platforms list is what you're using inside of your cluster. ArgoCD? Flux? Istio? Linkerd? Datadog? Figure out what you'll be implementing.

As you can see, Day Zero is all about PLANNING.

### Kubernetes Day One

Kubernetes Day One consists of:

- Figuring out how you're deploying clusters
- Network deployment and architecture
- Cluster deployments
- App deployments
- Cost and resource optimization
- Secrets management

First, ensure that you know how you want the clusters to be deployed and who will be using them. Is each cluster for each team or customer? Will multiple teams/customers use them?

Networking is arguably the most importante piece of a cluster and app deployment. Without proper networking, clusters will not work as expected and apps will be unusable.

Cluster and app deployments in Day One are all about the initial deployment of the kubernetes environment and the applications running inside of the environment.

Resource and cost optimization is to ensure that the deployments, both from a cluster and app perspective are performing as expected.

Last but certainly not least is secrets management. After all, you can't deploy a containerized app that has secrets if there's no way to properly and securely manage those secrets.

Day One is all about the first DEPLOYMENTS.

### Kubernetes Day Two

Kubernetes Day Two consists of:

- Upgrades
- Cluster and app scaling
- Security implementations and service mesh
- Monitoring and observability
- Backups
- Testing

Upgrading clusters can be a major pain depending on how and where you're running kubernetes. Ensure that this is properly tested and vetted out.

When it comes to scaling, you'll need to think both from a cluster and app perspective. You won't know how to scale until clusters and apps are deployed, so the idea here is to use resource optimization to see how you'll need to scale.

Security and service mesh were planned in Day Zero, but are actually implemented in Day Two. Why? Because you can't secure something that doesn't yet exist.

Monitoring and observability are implemented in Day Two for the same reason as security - if there's nothing to monitor, it won't have much use.

Failover and testing are all about ensuring that your clusters and apps can withstand a catastrophic failure or attack. Testing with tools like kubescape, kube-bench, and chaos-mesh will definitely help here.

Day Two is all about what comes NEXT.

## Environments

- **ENG** environment provides **Shared Infrastructure** for the following App Environments:
    - **DEV** environment is used for developer’s tasks, like merging commits in the first place, running unit tests. Dev environment is usually not guaranteed to be stable. The operation can be disrupted by commit, and it doesn’t do harm for the whole company. DEV environment is usually hooked to some CI/CD system. When developers do code merge, the build is automatically triggered, and application code is automatically redeployed to Dev.
    - **QA** is for testing by Quality Assurance team, both manual and automated, including running automated integration tests. It’s considered to be more stable than Dev, because code doesn't change so often on every merge, as in Dev.
    So, developers cannot disrupt ongoing work of QA engineers by “risky” change.
    - **UAT (User Acceptance Testing)** environment is for pre-release testing, the environment in which user acceptance testing is performed. Note the emphasis on user - your QA testing is different, UAT is a chance for actual users (or at least your training team, sales, support staff etc...) to try out new features and evaluate the software before it is deployed to their production systems. It is used by QA engineers, business analysts, product owners, for verifying functional requirements. UAT is required to be stable, because it’s used not only by developers but also by business users , who serve as “functional testers”. It also can be used as demo environment for showing new features to the customers. What this means exactly will depend on your processes:
        - UAT (the environment) might be "level" with production, and is essentially a sandbox for users to try new features with.
        - UAT (the environment) might be "ahead" of production, so that new features are not deployed to production until they have been evaluated. (I'm not keen on this approach as it necessarily means you have longer lead times).
        - It you have a multi-tenant system you might not even need a UAT environment, instead you could choose to have users evaluate new features in production systems by making use of feature flags.
    - **Staging aka Pre-production (PRE)** environment is often set up with a copy of production data, sometimes sanitized. Many organizations regularly "refresh" their staging database from a production snapshot. The primary focus is to ensure that the application will work in production the same way it worked in UAT. Instead of setting up new data, testers will search the database for profiles and products that match an essential set of test cases. Often the "real" data have quirks in them that give rise to unexpected edge cases that were missed during UAT. Also, any data migration testing would need to take place in the staging environment.
- **PRO** environment provides **Shared Infrastructure** for the following App Environments:
    - **PRO** is production environment, serving primary business purpose. Access of developers to it usually limited only to perform technical support duties.
    - **DEM** (DEMO) environment is for Enterprise´s Business/Sales Demos. **It is considered as a critical/production environment.**

### Matrix table

| Shared-Infra Env | App Env        | Service Principal in AAD | Service Connection in Azure DevOps | Deployment Target Azure Subscription                                                                                                      |
|:-----------------|:---------------|:-------------------------|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|
| ENG              | DEV,QA,UAT,PRE | sp-day2ops-enterprise-dev    | svccon-day2ops-dev                 | [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) |
| PRO              | PRO,DEM        | sp-day2ops-enterprise-pro    | svccon-day2ops-pro                 | [Enterprise Production Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview)    |

### Matrix table with Azure DevOps Service Connections

| Azure DevOps Service Connection | Service Principal in AAD | Azure Subscription                                                                                                                        | Details                                                                      |
|:--------------------------------|:-------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------|
| svccon-day2ops-devops           | sp-day2ops-enterprise-devops | [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users)     | This is the Azure Subscription **where Terraform TFSTATE files are located** |
| svccon-day2ops-dev              | sp-day2ops-enterprise-dev    | [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) | A Non-Production Deployment Target Subscription                              |
| svccon-day2ops-pro              | sp-day2ops-enterprise-pro    | [Enterprise Production Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview)    | A Production Deployment Target Subscription                                  |

## Requirements

1. Environment: Azure **Enterprise DevOps Subscription**
2. [Azure DevOps Terraform Extension: Terraform by Microsoft DevLabs](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
3. Azure DevOps Environments: Make sure the following environments are defined in [Azure DevOps environments](https://dev.azure.com/EnterpriseDev/Shared-Infra/_environments):
    - eng
    - pro
4. **sp-day2ops-enterprise-devops** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
    - The following application role (Microsoft Graph - Application permissions):
        - **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf](terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf) .
        - **RoleManagement.ReadWrite.Directory**: Otherwise this pipeline won't be able to run azuread_group.aks_administrators and azuread_group.aks_developers
        - Click on "Grant admin consent for enterprise.com"
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
5. **sp-day2ops-enterprise-dev** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
    - The following application role (Microsoft Graph - Application permissions):
        - **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf](terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf) .
        - **RoleManagement.ReadWrite.Directory**: Otherwise this pipeline won't be able to run azuread_group.aks_administrators and azuread_group.aks_developers
        - Click on "Grant admin consent for enterprise.com"
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
6. **sp-day2ops-enterprise-pro** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
    - The following application role (Microsoft Graph - Application permissions):
        - **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf](terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf) .
        - **RoleManagement.ReadWrite.Directory**: Otherwise this pipeline won't be able to run azuread_group.aks_administrators and azuread_group.aks_developers
        - Click on "Grant admin consent for enterprise.com"
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
7. Add the following Service Principals to "AAD Management Scope - Azure AD Roles - Application administrator | Assignments" (Scope type: Directory) required by kubeapps helm chart in order to being registered in AAD with msgraph (resource azuread_service_principal.msgraph):
    - **sp-day2ops-enterprise-devops**
    - **sp-day2ops-enterprise-dev**
    - **sp-day2ops-enterprise-pro**
8. **Built-in RBAC Permissions** [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users) (Subscription Scope):
    - This is the Azure Subscription **where Terraform TFSTATE files are located**.
    - Access Control (IAM) -> Role Assignments -> **"Owner"** assigned to:
        - **sp-day2ops-enterprise-devops**
        - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
            - Dedicated administrators group for this Azure Subscription
            - Conditon: None
9. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope):
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (roles like 'Contributor' or 'API Management Service Contributor' are not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - Assigned to:
                - **sp-day2ops-enterprise-dev**  (it needs to assign roles in Azure RBAC)
                - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                    - Dedicated administrators group for this Azure Subscription
                    - Conditon: None
10. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise Production Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope):
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (roles like 'Contributor' or 'API Management Service Contributor' are not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - Assigned to:
                - **sp-day2ops-enterprise-pro**  (it needs to assign roles in Azure RBAC)
                - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                    - Dedicated administrators group for this Azure Subscription
                    - Conditon: None
11. Azure DevOps [svccon-day2ops-devops Service Connection](https://dev.azure.com/EnterpriseDev/Shared-Infra/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise DevOps Subscription)
    - Subscription Name: **Enterprise DevOps Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-day2ops-enterprise-devops)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-day2ops-devops**
    - Description: Connects to Enterprise DevOps Subscription via sp-day2ops-enterprise-devops, a deployment target subscription and **where Terraform TFSTATE files are located**.
    - Grant access permissions to all pipelines: **enabled**
12. Azure DevOps [svccon-day2ops-dev Service Connection](https://dev.azure.com/EnterpriseDev/Shared-Infra/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise DevTest Subscription)
    - Subscription Name: **Enterprise DevTest Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-day2ops-enterprise-dev)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-day2ops-dev**
    - Description: Connects to Enterprise DevTest Subscription via sp-day2ops-enterprise-dev, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**
13. Azure DevOps [svccon-day2ops-pro Service Connection](https://dev.azure.com/EnterpriseDev/Shared-Infra/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise Production Subscription)
    - Subscription Name: **Enterprise Production Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-day2ops-enterprise-pro)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-day2ops-pro**
    - Description: Connects to Enterprise Production Subscription via sp-day2ops-enterprise-pro, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**
14. Azure DevOps Pipeline Library:
    - [Secure files](https://dev.azure.com/EnterpriseDev/Shared-Infra/_library?itemType=SecureFiles):
        - Generated SSH Public Key uploaded to [Azure DevOps Pipeline -> Library -> Secure Files](https://dev.azure.com/EnterpriseDev/Shared-Infra/_library?itemType=SecureFiles)
15. Manually grant **'Key Vault Reader'** RBAC permissions on **[kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/users)** to the following service principals ~~(we don't want to automate the assignment of these permissions since kv-wildcards-enterprise-com belongs to a different Azure Subscription)~~:
    1. sp-day2ops-enterprise-devops
    2. sp-day2ops-enterprise-dev
    3. sp-day2ops-enterprise-pro
    4. ~~webapprouting-aks-dneeng~~
    5. ~~webapprouting-aks-neeng~~
    6. ~~webapprouting-aks-cuseng~~
    7. ~~webapprouting-aks-neapps~~
    8. ~~webapprouting-aks-cusapps~~
16. Manually grant **'Key Vault Secrets User'** RBAC permissions on **[kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/users)** to the following service principals:
    1. sp-day2ops-enterprise-devops
    2. sp-day2ops-enterprise-dev
    3. sp-day2ops-enterprise-pro
17. These permissions are required to deploy k8s resources with several terraform providers (kubernetes, helm, ansible, kubectl):
    1. **Built-in RBAC Permissions** on [aks-dneeng](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sharedinfra-aks-dneeng/providers/Microsoft.ContainerService/managedClusters/aks-dneeng/overview) (Kubernetes Service Scope):
       - Access Control (IAM) -> Role Assignments -> **"Azure Kubernetes Service RBAC Cluster Admin"** assigned to **sp-day2ops-enterprise-devops**
    2. **Built-in RBAC Permissions** on [aks-neeng](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sharedinfra-aks-neeng/providers/Microsoft.ContainerService/managedClusters/aks-neeng/overview) (Kubernetes Service Scope):
       - Access Control (IAM) -> Role Assignments -> **"Azure Kubernetes Service RBAC Cluster Admin"** assigned to **sp-day2ops-enterprise-dev**
    3. **Built-in RBAC Permissions** on [aks-nepro](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sharedinfra-aks-nepro/providers/Microsoft.ContainerService/managedClusters/aks-nepro/overview) (Kubernetes Service Scope):
       - Access Control (IAM) -> Role Assignments -> **"Azure Kubernetes Service RBAC Cluster Admin"** assigned to **sp-day2ops-enterprise-pro**

## References

- Kubecost: https://www.kubecost.com/
- OpenCost:
    - https://www.opencost.io/
    - https://www.infoworld.com/article/3695569/kubernetes-cost-management-for-the-real-world.html
