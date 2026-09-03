# Table of Contents

1. [Enterprise Shared Infra Automation and Self-Service](#enterprise-shared-infra-automation-and-self-service)
2. [Automation Glossary](#automation-glossary)
3. [Shared-Infra Environments](#shared-infra-environments)
   1. [Matrix table](#matrix-table)
   2. [Matrix table with Azure DevOps Service Connections](#matrix-table)
4. [Requirements](#requirements)
5. [Built-in Roles in Azure](#built-in-roles-in-azure)
6. [Azure Regions](#azure-regions)
   1. [Azure Region Codes aka Short Notation in Cloud Resource Naming Convention - Azure Naming rules and restrictions](#azure-region-codes-aka-short-notation-in-cloud-resource-naming-convention---azure-naming-rules-and-restrictions)
7. [VSCode settings](#vscode-settings)
8. [References](#references)

## Enterprise Shared Infra Automation and Self-Service

This repo contains two **Azure DevOps IaC pipelines** that deploy, update and destroy **Enterprise Shared Infrastructure** on Azure with Azure DevOps and Terraform. All of these automated pipelines **run in parallel**.
<>
Recommended references:

- [Introduction to Kubernetes](https://www.cloudtechtwitter.com/2022/05/dont-miss-next-article-be-first-to-be.html)
- [Azure AKS Kubernetes masterclass (slides)](https://github.com/stacksimplify/azure-aks-kubernetes-masterclass/tree/master/ppt-presentation)
- [learn.microsoft.com: AKS Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
- [learn.microsoft.com: Microservices Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks-microservices/aks-microservices)

Environments are automatically created, updated and destroyed via Azure DevOps Pipelines. These pipelines might require [approvals](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals) in order to accept or reject changes. A [GitOps pattern](https://developers.redhat.com/articles/2022/07/20/git-workflows-best-practices-gitops-deployments) (the correct way of doing DevOps) with Terraform is the approach being used here. Terraform is an Infrastructure as Code solution (IaC).

A **Gitflow** branching model is currently setup on this configuration repository. It involves creating two main branches - “main” and “develop” - and using feature branches to develop new features. Once a feature is complete, it is merged into the “develop” branch. When the “develop” branch is stable, it is merged into the “main” branch:

- **main** branch with a **dedicated** terraform **state** file.
- **develop** branch and **other develop** branches with a **shared** terrraform **state** file:
    - All the existing branches **except main branch** are develop branches.
    - **develop** branch is the main development branch.
    - We can work on separated branches for development purposes (*development* branch, *develop_feature* branch, *feature/item* branch, *bugfix/item* branch, etc), with **all of them sharing the same terraform state file**. Check *"GIT_BRANCH"* var in:
        - [configuration/variable-group-with-secrets.yml](configuration/variable-group-with-secrets.yml)
        - [templates/terraform-validate.yml](templates/terraform-validate.yml)
        - [templates/terraform-plan.yml](templates/terraform-plan.yml)
        - [templates/terraform-apply.yml](templates/terraform-apply.yml)
        - [templates/terraform-destroy.yml](templates/terraform-destroy.yml)
    - Therefore, we can have several development branches with different solutions / architecture designs in case we are not sure which one is the *winning horse*.
    - **Make sure you only have one azure devops develop pipeline** pointing out to one of these git branches, otherwise more than one pipeline could have access to the same terraform state file. Each running pipeline acquires the lock of the terraform state file [to prevent others from corrupting your state](https://www.terraform.io/language/state/locking).
    - Having a dedicated state file per git branch is another option, but **we want to reuse the already deployed resources with different settings per branch** (faster than creating all the resources from scratch).



**Azure Multi-Region feature**: We are now able to deploy App-Core on both **Azure Europe** and **Azure United States** regions. This process is **fully automated with one single click** and it will help us to be more efficient while also improving the quality of our products.

Two environments have been defined: **ENG** and **PRO**. A **“Self-Service approach”** is not recommended on shared infrastructure. Security is achieved via permissions and approvals.

One of my favourite quotes that motivates me to implement automation:

[*“The absolutely difficult thing is reaching volume production without going bankrupt, that is the actual hard thing”*](https://www.youtube.com/watch?v=cdZZpaB2kDM&t=2024s) Elon Musk

## Automation Glossary

- **Infrastructure as code (IaC)** is the managing and provisioning of infrastructure through code instead of through manual processes. With IaC, configuration files contain your infrastructure specifications, making them easier to edit and distribute. This also ensures consistency in the environments you provision, and helps aid in configuration management.
- **Configuration management** is a process for maintaining computer systems, servers, and software in a consistent desired state. It ensures that a system performs as expected as changes are made over time. Configuration management can be automated, reducing cost, complexity and the chance for errors.
- **Terraform is declarative and idempotent:**
    - Terraform configuration files are **declarative**, meaning that they describe the end state of your infrastructure. You do not need to write step-by-step instructions to create resources because Terraform handles the underlying logic.
    - A Terraform configuration is **idempotent** when a second apply results in 0 changes. An idempotent configuration ensures that: What you define in Terraform is exactly what is being deployed. Detection of bugs in Terraform resources and providers that might affect your configuration.
    - Cloud resources created using Terraform are maintained using Infrastructure as Code. Any changes, commissioning, and decommissioning of resources are supposed to be handled using IaC. **Teams who have adapted Terraform for infrastructure management usually have strict compliance with manual changes via the web console.**
- **GitOps** is an approach to managing infrastructure and application configurations using Git, an open source version control system. GitOps works by using Git as a single source of truth for declarative infrastructure and applications.
    - GitOps uses **Git pull requests** to automatically manage infrastructure provisioning and deployment, allowing teams to manage infrastructure using the same tools and processes they use for software development.
- **[Trunk-based development](https://developers.redhat.com/articles/2022/07/20/git-workflows-best-practices-gitops-deployments):** This method defines one branch as the "trunk" and carries out development on each environment in a different short-lived branch. When development is complete for that environment, the developer creates a pull request for the branch to the trunk. Developers can also create a fork to work on an environment, and then create a branch to merge the fork into the trunk.
    - Once the proper approvals are done, the pull request (or the branch from the fork) gets merged into the trunk. The branch for that feature is deleted, keeping your branches to a minimum. Trunk-based development trades branches for directories.
    - You can think of the trunk as a "main" or primary branch. production and prod are popular names for the trunk branch.
    - Trunk-based development came about to enable continuous integration and continuous delivery by supplying a development model focused on the fast delivery of changes to applications. But this model also works for GitOps repositories because it keeps things simple. When you record deltas between environments, you can clearly see what changes will be merged into the trunk. You won’t have to cherry-pick nearly as often, and you’ll have the confidence that what is in your Git repository is what is actually going into your environment. This is what you want in a GitOps workflow.
- An [**immutable infrastructure**](https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure) is another infrastructure paradigm in which servers are never modified after they’re deployed. If something needs to be updated, fixed, or modified in any way, new servers built from a common image with the appropriate changes are provisioned to replace the old ones. After they’re validated, they’re put into use and the old ones are decommissioned.
    - The benefits of an immutable infrastructure include more consistency and reliability in your infrastructure and a simpler, more predictable deployment process. It mitigates or entirely prevents issues that are common in mutable infrastructures, like **configuration drift** and **snowflake servers**. However, using it efficiently often includes comprehensive deployment automation, fast server provisioning in a cloud computing environment, and solutions for handling stateful or ephemeral data like logs.
    - **Normal Flow:**      Develop ---> Deploy    ---> Configure
    - **Immutable Flow:**   Develop ---> Configure ---> Deploy

- **Configuration Drift** occurs when unplanned changes happen and a resource’s configuration moves away from the designed baseline. Drift is common because of frequent software and hardware updates, particularly in a colocation facility or when using virtual machines.
    - Production, staging, development and recovery configurations are designed to be identical (or near identical) to maintain consistency. As the configurations in the different environments change, a configuration gap develops, which can lead to a variety of issues, including disaster recovery and high availability failures.
- In DevOps, a **snowflake** is a server that requires special configuration beyond that covered by automated deployment scripts. You do the automated deployment, and then you tweak the snowflake system by hand. For a long time (through the '90s, at least), snowflake configurations were the rule.
- **Self Service in Infrastructure:**
    - [The problem: Ticket based systems for provisioning Infrastructure](https://dabase.com/blog/2022/devops-self-service/)
    - [Self-service in DevOps](https://www.lucidchart.com/blog/self-service-in-devops): Before DevOps self-servicing, software engineers typically built an application or a product feature and then waited for the IT operators to “dispatch” it. With self-service DevOps, however, engineers are no longer dependent on a separate team of IT operators to bring their product features to life. Instead, DevOps teams can build infrastructure that allows software engineers to deploy updates without waiting for DevOps resources to become available.
        - As the rate of software innovation has accelerated, it’s become clear that the traditional way of working (where a centralized IT team handled the automated procedures and were the gatekeepers to executing tasks) no longer makes sense. Developers spent time waiting for the operations team to **respond to a ticket request** and additional time was lost as the operation team tried to make sense of the new feature in the live environment.
        - This is why, according to The New Stack, tech companies first popularized the idea of DevOps—dispersing centralized IT functions throughout the organization and embedding operations engineers within development teams. While this worked for tech companies, other enterprises struggled to adopt DevOps roles at scale. Services like AWS, Azure, and Google began offering IT services on-demand to help the average company adopt the DevOps model. But self-service DevOps is more than just picking IT capabilities from a menu.
        - Self-service DevOps can break down silos and increase productivity, but, like any process, it can be challenging to implement in the beginning. One roadblock can be an increase in costs. With engineers able to deploy at scale, it’s a good idea to put parameters in place.
        - According to Stelligent, one way to control costs is to launch smaller instances. That is, use less expensive servers to maintain your infrastructure while also creating and keeping autoscaling policies so that a spike in demand doesn’t automatically translate to a spike in costs. Another strategy is to use mock services instead of always deploying to a live environment.
        - You’ll also want to ensure that self-service automation doesn’t lead to engineers going rogue. Be sure to design parameters within the on-demand self-service environment that the engineers understand. Stelligent recommends thinking about **a one-button deployment**, with distinct options and a failsafe built into the pipeline. Having strict parameters in place also helps mitigate security concerns.

## Shared-Infra Environments

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

| Shared-Infra Env | App Env        | Service Principal in AAD  | Service Connection in Azure DevOps | Deployment Target Azure Subscription                                                                                                      |
|:-----------------|:---------------|:--------------------------|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|
| ENG              | DEV,QA,UAT,PRE | sp-sharedinfra-enterprise-dev | svccon-sharedinfra-dev             | [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) |
| PRO              | PRO,DEM        | sp-sharedinfra-enterprise-pro | svccon-sharedinfra-pro             | [Enterprise Production Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview)    |

### Matrix table with Azure DevOps Service Connections

| Azure DevOps Service Connection | Service Principal in AAD     | Azure Subscription                                                                                                                        | Details                                                                      |
|:--------------------------------|:-----------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------|
| svccon-sharedinfra-devops       | sp-sharedinfra-enterprise-devops | [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users)     | This is the Azure Subscription **where Terraform TFSTATE files are located** |
| svccon-sharedinfra-dev          | sp-sharedinfra-enterprise-dev    | [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) | A Non-Production Deployment Target Subscription                              |
| svccon-sharedinfra-pro          | sp-sharedinfra-enterprise-pro    | [Enterprise Production Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview)    | A Production Deployment Target Subscription                                  |

## Requirements

1. Environment: Azure **Enterprise DevOps Subscription**
2. [Azure DevOps Terraform Extension: Terraform by Microsoft DevLabs](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
3. Azure DevOps Environments: Make sure the following environments are defined in [Azure DevOps environments](https://dev.azure.com/EnterpriseDev/Shared-Infra/_environments):
    - eng
    - pro
4. **sp-sharedinfra-enterprise-devops** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
    - The following application role (Microsoft Graph - Application permissions):
        - **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf](terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf) .
        - **RoleManagement.ReadWrite.Directory**: Otherwise this pipeline won't be able to run azuread_group.aks_administrators and azuread_group.aks_developers
        - Click on "Grant admin consent for enterprise.com"
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
5. **sp-sharedinfra-enterprise-dev** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
    - The following application role (Microsoft Graph - Application permissions):
        - **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf](terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf) .
        - **RoleManagement.ReadWrite.Directory**: Otherwise this pipeline won't be able to run azuread_group.aks_administrators and azuread_group.aks_developers
        - Click on "Grant admin consent for enterprise.com"
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
6. **sp-sharedinfra-enterprise-pro** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
    - The following application role (Microsoft Graph - Application permissions):
        - **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf](terraform-manifests/modules/sharedinfra_aks_module/06-aks-administrators-azure-ad.tf) .
        - **RoleManagement.ReadWrite.Directory**: Otherwise this pipeline won't be able to run azuread_group.aks_administrators and azuread_group.aks_developers
        - Click on "Grant admin consent for enterprise.com"
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
7. Add the following Service Principals to [AAD Management Scope - Azure AD Roles - Application administrator | Asignments](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/00000000-0000-0000-0000-000000000000/roleId/00000000-0000-0000-0000-000000000000/roleTemplateId/00000000-0000-0000-0000-000000000000/roleName/Application%20administrator/isRoleCustom~/false/resourceScopeId/%2F/resourceId/00000000-0000-0000-0000-000000000000) (Scope type: Directory) required by kubeapps helm chart in order to being registered in AAD with msgraph (resource azuread_service_principal.msgraph):
    - **sp-sharedinfra-enterprise-devops**
    - **sp-sharedinfra-enterprise-dev**
    - **sp-sharedinfra-enterprise-pro**
8. **Built-in RBAC Permissions** [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users) (Subscription Scope):
    - This is the Azure Subscription **where Terraform TFSTATE files are located**.
    - Access Control (IAM) -> Role Assignments -> **"Owner"** assigned to:
        - **sp-sharedinfra-enterprise-devops**
        - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
            - Dedicated administrators group for this Azure Subscription
            - Conditon: None
9. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope):
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (roles like 'Contributor' or 'API Management Service Contributor' are not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - Assigned to:
                - **sp-sharedinfra-enterprise-dev**  (it needs to assign roles in Azure RBAC)
                - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                    - Dedicated administrators group for this Azure Subscription
                    - Conditon: None
10. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise Production Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope):
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (roles like 'Contributor' or 'API Management Service Contributor' are not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - Assigned to:
                - **sp-sharedinfra-enterprise-pro**  (it needs to assign roles in Azure RBAC)
                - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                    - Dedicated administrators group for this Azure Subscription
                    - Conditon: None
11. Azure DevOps [svccon-sharedinfra-devops Service Connection](https://dev.azure.com/EnterpriseDev/Shared-Infra/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise DevOps Subscription)
    - Subscription Name: **Enterprise DevOps Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-sharedinfra-enterprise-devops)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-sharedinfra-devops**
    - Description: Connects to Enterprise DevOps Subscription via sp-sharedinfra-enterprise-devops, a deployment target subscription and **where Terraform TFSTATE files are located**.
    - Grant access permissions to all pipelines: **enabled**
12. Azure DevOps [svccon-sharedinfra-dev Service Connection](https://dev.azure.com/EnterpriseDev/Shared-Infra/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise DevTest Subscription)
    - Subscription Name: **Enterprise DevTest Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-sharedinfra-enterprise-dev)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-sharedinfra-dev**
    - Description: Connects to Enterprise DevTest Subscription via sp-sharedinfra-enterprise-dev, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**
13. Azure DevOps [svccon-sharedinfra-pro Service Connection](https://dev.azure.com/EnterpriseDev/Shared-Infra/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise Production Subscription)
    - Subscription Name: **Enterprise Production Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-sharedinfra-enterprise-pro)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-sharedinfra-pro**
    - Description: Connects to Enterprise Production Subscription via sp-sharedinfra-enterprise-pro, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**
14. Access control (IAM)/RBAC: **DNS Zone Contributor** in [Enterprise Infrastructure Subscription - InfrastructureResourceGroup RG - DNS zones - enterprise.com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/InfrastructureResourceGroup/providers/Microsoft.Network/dnszones/enterprise.com/overview):
    - **sp-sharedinfra-enterprise-dev**
    - Required by [ns-name-servers.tf](terraform-manifests/modules/dns_top_level_domain_module/dns.tf)
15. Access control (IAM)/RBAC: **DNS Zone Contributor** in [Enterprise Infrastructure Subscription - InfrastructureResourceGroup RG - DNS zones - enterprise.com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/InfrastructureResourceGroup/providers/Microsoft.Network/dnszones/enterprise.com/overview):
    - **sp-sharedinfra-enterprise-pro**
    - Required by [ns-name-servers.tf](terraform-manifests/modules/dns_top_level_domain_module/dns.tf)
16. Access control (IAM)/RBAC: **DNS Zone Contributor** in [Enterprise Infrastructure Subscription - InfrastructureResourceGroup RG - DNS zones - enterprise.com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/InfrastructureResourceGroup/providers/Microsoft.Network/dnszones/enterprise.com/overview):
    - **sp-sharedinfra-enterprise-devops**
    - Required by [ns-name-servers.tf](terraform-manifests/modules/dns_top_level_domain_module/dns.tf)
17. Azure DevOps Pipeline Library:
    - [Secure files](https://dev.azure.com/EnterpriseDev/Shared-Infra/_library?itemType=SecureFiles):
        - Generated SSH Public Key uploaded to [Azure DevOps Pipeline -> Library -> Secure Files](https://dev.azure.com/EnterpriseDev/Shared-Infra/_library?itemType=SecureFiles)
18. Manually grant **'Key Vault Reader'** RBAC permissions on **[kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/users)** to the following service principals (we don't want to automate the assignment of these permissions since kv-wildcards-enterprise-com belongs to a different Azure Subscription):
    1. **webapprouting-aks-dneeng**
    2. **webapprouting-aks-neeng**
    3. **webapprouting-aks-cuseng**
    4. **webapprouting-aks-neapps**
    5. **webapprouting-aks-cusapps**
    6. **sp-sharedinfra-enterprise-dev**
    7. **sp-sharedinfra-enterprise-devops**
    8. **sp-sharedinfra-enterprise-pro**
    9. etc

## Built-in Roles in Azure

- [Azure built-in roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)

- General:
    - Owner - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
    - Contributor - Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries.
    - Reader - View all resources, but does not allow you to make any changes.
    - User Access Administrator - Lets you manage user access to Azure resources.

- Security:
    - Key Vault Administrator - Perform all data plane operations on a key vault and all objects in it, including certificates, keys, and secrets. Cannot manage key vault resources or manage role assignments. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Certificates Officer - Perform any action on the certificates of a key vault, except manage permissions. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Contributor - Lets you manage key vaults, but not access to them.
    - Key Vault Crypto Officer - Perform any action on the keys of a key vault, except manage permissions. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Crypto Service Encryption User - Read metadata of keys and perform wrap/unwrap operations. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Crypto User - Perform cryptographic operations using keys. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Reader - Read metadata of key vaults and its certificates, keys, and secrets. Cannot read sensitive values such as secret contents or key material. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Secrets Officer - Perform any action on the secrets of a key vault, except manage permissions. Only works for key vaults that use the 'Azure role-based access control' permission model.
    - Key Vault Secrets User - Read secret contents. Only works for key vaults that use the 'Azure role-based access control' permission model.

- Analytics:
    - Log Analytics Contributor - Log Analytics Contributor can read all monitoring data and edit monitoring settings. Editing monitoring settings includes adding the VM extension to VMs; reading storage account keys to be able to configure collection of logs from Azure Storage; adding solutions; and configuring Azure diagnostics on all Azure resources.
    - Log Analytics Reader - Log Analytics Reader can view and search all monitoring data as well as and view monitoring settings, including viewing the configuration of Azure diagnostics on all Azure resources.

- Management + Governance:
    - Managed Application Contributor Role - Allows for creating managed application resources.
    - Managed Application Operator Role - Lets you read and perform actions on Managed Application resources
    - Managed Applications Reader - Lets you read resources in a managed app and request JIT access.
    - Resource Policy Contributor - Users with rights to create/modify resource policy, create support ticket and read resources/hierarchy.

- Monitor:
    - Monitoring Contributor - Can read all monitoring data and update monitoring settings.
    - Monitoring Metrics Publisher - Enables publishing metrics against Azure resources
    - Monitoring Reader - Can read all monitoring data.

## Azure Regions

- [Find the Azure geography that meets your needs](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#geographies)
- Run the following command to list all Azure Regions (the second column with the region names used by terraform):

    ```az account list-locations -o table```

    <details>
    <summary>az account list-locations -o table. Click to expand!</summary>

    | DisplayName              | Name                | RegionalDisplayName                   |
    |--------------------------|---------------------|---------------------------------------|
    | East US                  | eastus              | (US) East US                          |
    | East US 2                | eastus2             | (US) East US 2                        |
    | South Central US         | southcentralus      | (US) South Central US                 |
    | West US 2                | westus2             | (US) West US 2                        |
    | West US 3                | westus3             | (US) West US 3                        |
    | Australia East           | australiaeast       | (Asia Pacific) Australia East         |
    | Southeast Asia           | southeastasia       | (Asia Pacific) Southeast Asia         |
    | North Europe             | northeurope         | (Europe) North Europe                 |
    | Sweden Central           | swedencentral       | (Europe) Sweden Central               |
    | UK South                 | uksouth             | (Europe) UK South                     |
    | West Europe              | westeurope          | (Europe) West Europe                  |
    | Central US               | centralus           | (US) Central US                       |
    | South Africa North       | southafricanorth    | (Africa) South Africa North           |
    | Central India            | centralindia        | (Asia Pacific) Central India          |
    | East Asia                | eastasia            | (Asia Pacific) East Asia              |
    | Japan East               | japaneast           | (Asia Pacific) Japan East             |
    | Korea Central            | koreacentral        | (Asia Pacific) Korea Central          |
    | Canada Central           | canadacentral       | (Canada) Canada Central               |
    | France Central           | francecentral       | (Europe) France Central               |
    | Germany West Central     | germanywestcentral  | (Europe) Germany West Central         |
    | Norway East              | norwayeast          | (Europe) Norway East                  |
    | Switzerland North        | switzerlandnorth    | (Europe) Switzerland North            |
    | UAE North                | uaenorth            | (Middle East) UAE North               |
    | Brazil South             | brazilsouth         | (South America) Brazil South          |
    | East US 2 EUAP           | eastus2euap         | (US) East US 2 EUAP                   |
    | Qatar Central            | qatarcentral        | (Middle East) Qatar Central           |
    | Central US (Stage)       | centralusstage      | (US) Central US (Stage)               |
    | East US (Stage)          | eastusstage         | (US) East US (Stage)                  |
    | East US 2 (Stage)        | eastus2stage        | (US) East US 2 (Stage)                |
    | North Central US (Stage) | northcentralusstage | (US) North Central US (Stage)         |
    | South Central US (Stage) | southcentralusstage | (US) South Central US (Stage)         |
    | West US (Stage)          | westusstage         | (US) West US (Stage)                  |
    | West US 2 (Stage)        | westus2stage        | (US) West US 2 (Stage)                |
    | Asia                     | asia                | Asia                                  |
    | Asia Pacific             | asiapacific         | Asia Pacific                          |
    | Australia                | australia           | Australia                             |
    | Brazil                   | brazil              | Brazil                                |
    | Canada                   | canada              | Canada                                |
    | Europe                   | europe              | Europe                                |
    | France                   | france              | France                                |
    | Germany                  | germany             | Germany                               |
    | Global                   | global              | Global                                |
    | India                    | india               | India                                 |
    | Japan                    | japan               | Japan                                 |
    | Korea                    | korea               | Korea                                 |
    | Norway                   | norway              | Norway                                |
    | Singapore                | singapore           | Singapore                             |
    | South Africa             | southafrica         | South Africa                          |
    | Switzerland              | switzerland         | Switzerland                           |
    | United Arab Emirates     | uae                 | United Arab Emirates                  |
    | United Kingdom           | uk                  | United Kingdom                        |
    | United States            | unitedstates        | United States                         |
    | United States EUAP       | unitedstateseuap    | United States EUAP                    |
    | East Asia (Stage)        | eastasiastage       | (Asia Pacific) East Asia (Stage)      |
    | Southeast Asia (Stage)   | southeastasiastage  | (Asia Pacific) Southeast Asia (Stage) |
    | East US STG              | eastusstg           | (US) East US STG                      |
    | South Central US STG     | southcentralusstg   | (US) South Central US STG             |
    | North Central US         | northcentralus      | (US) North Central US                 |
    | West US                  | westus              | (US) West US                          |
    | Jio India West           | jioindiawest        | (Asia Pacific) Jio India West         |
    | Central US EUAP          | centraluseuap       | (US) Central US EUAP                  |
    | West Central US          | westcentralus       | (US) West Central US                  |
    | South Africa West        | southafricawest     | (Africa) South Africa West            |
    | Australia Central        | australiacentral    | (Asia Pacific) Australia Central      |
    | Australia Central 2      | australiacentral2   | (Asia Pacific) Australia Central 2    |
    | Australia Southeast      | australiasoutheast  | (Asia Pacific) Australia Southeast    |
    | Japan West               | japanwest           | (Asia Pacific) Japan West             |
    | Jio India Central        | jioindiacentral     | (Asia Pacific) Jio India Central      |
    | Korea South              | koreasouth          | (Asia Pacific) Korea South            |
    | South India              | southindia          | (Asia Pacific) South India            |
    | West India               | westindia           | (Asia Pacific) West India             |
    | Canada East              | canadaeast          | (Canada) Canada East                  |
    | France South             | francesouth         | (Europe) France South                 |
    | Germany North            | germanynorth        | (Europe) Germany North                |
    | Norway West              | norwaywest          | (Europe) Norway West                  |
    | Switzerland West         | switzerlandwest     | (Europe) Switzerland West             |
    | UK West                  | ukwest              | (Europe) UK West                      |
    | UAE Central              | uaecentral          | (Middle East) UAE Central             |
    | Brazil Southeast         | brazilsoutheast     | (South America) Brazil Southeast      |

    </details>

### Azure Region Codes aka Short Notation in Cloud Resource Naming Convention - Azure Naming rules and restrictions

- Official Azure Region Names cannot be used when creating resource names by terraform due to existing [naming rules and restrictions for Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules). Examples:
    - Azure limits the length of key vault name, being limited to alphanumeric characters and dashes and must be between 3-24 char.
    - Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
- It is preferred to shorten the naming scheme by using Azure Region codes:

    <details>
        <summary>Azure Region Codes aka Short Notation. Click to expand!</summary>

    | Geography              | Country      | Region                 | Code |
    |------------------------|--------------|------------------------|:----:|
    | Americas               | USA          | Central US             | CUS  |
    | Americas               | USA          | East US 2              | EUS2 |
    | Americas               | USA          | East US                | EUS  |
    | Americas               | USA          | North Central US       | NCUS |
    | Americas               | USA          | South Central US       | NSUS |
    | Americas               | USA          | West US 2              | WUS2 |
    | Americas               | USA          | West Central US        | WCUS |
    | Americas               | Azure Gov    | West US,US DoD Central | WUSD |
    | Americas               | Azure Gov    | US DoD East            | USDE |
    | Americas               | Azure Gov    | US Gov. Arizona        | USGA |
    | Americas               | Azure Gov    | US Gov. Iowa           | USGI |
    | Americas               | Azure Gov    | US Gov. Texas          | USGT |
    | Americas               | Azure Gov    | US Gov. Virginia       | USGV |
    | Americas               | Azure Gov    | US Sec East            | USSE |
    | Americas               | Azure Gov    | US Sec West            | USSW |
    | Americas               | Canada       | Canada Central         |  CC  |
    | Americas               | Canada       | Canade East            |  CE  |
    | Americas               | Brazil       | Brazil South           |  BS  |
    | Europe                 | Europe       | North Europe           |  NE  |
    | Europe                 | Europe       | West Europe            |  WE  |
    | Europe                 | UK           | UK South               | UKS  |
    | Europe                 | UK           | UK West                | UKW  |
    | Europe                 | Germany      | Germany North          |  GN  |
    | Europe                 | Germany      | Germany West Central   | GWC  |
    | Europe                 | Switzerland  | Switzerland North      |  SN  |
    | Europe                 | Switzerland  | Switzerland West       |  SW  |
    | Europe                 | Norway       | Norway West            |  NW  |
    | Europe                 | Norway       | Norway East            |  NE  |
    | Asia Pacific           | Asia Pacific | East Asia              |  EA  |
    | Asia Pacific           | Asia Pacific | Southeast Asia         |  SA  |
    | Asia Pacific           | Australia    | Australia Central      |  AC  |
    | Asia Pacific           | Australia    | Australia Central 2    | AC2  |
    | Asia Pacific           | Australia    | Australia East         |  AE  |
    | Asia Pacific           | Australia    | Australia Southeast    |  AS  |
    | Asia Pacific           | China        | China East             |  CE  |
    | Asia Pacific           | China        | China North            |  CN  |
    | Asia Pacific           | China        | China East 2           | CE2  |
    | Asia Pacific           | China        | China North 2          | CN2  |
    | Asia Pacific           | India        | Central India          |  CI  |
    | Asia Pacific           | India        | South India            |  SI  |
    | Asia Pacific           | India        | West India             |  WI  |
    | Asia Pacific           | Japan        | Japan East             |  JE  |
    | Asia Pacific           | Japan        | Japan West             |  JW  |
    | Asia Pacific           | Korea        | Korea Central          |  KC  |
    | Asia Pacific           | Korea        | Korea South            |  KS  |
    | Middle East and Africa | South Africa | South Africa North     | SAN  |
    | Middle East and Africa | South Africa | South Africa West      | SAW  |
    | Middle East and Africa | UAE          | UAE Central            |  UC  |
    | Middle East and Africa | UAE          | UAE North              |  UN  |

    </details>

- [Reference](https://blog.nicholasrogoff.com/2019/11/13/cloud-resource-naming-convention-azure/)

## VSCode settings

My VSCode's plugins:

- [Markdown All in One 🌟](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one) Tables of Contents are automatically generated with this extension.
- [markdownlint 🌟](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [GitLens — Git supercharged 🌟](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Git History 🌟](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)
- [Git Graph 🌟](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)
- [gitflow vector-of-bool](https://marketplace.visualstudio.com/items?itemName=vector-of-bool.gitflow)
- [HashiCorp Terraform 🌟](https://marketplace.visualstudio.com/items?itemName=hashicorp.terraform)
- [JSON Crack 🌟](https://marketplace.visualstudio.com/items?itemName=AykutSarac.jsoncrack-vscode)
- [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
- [GitLive](https://marketplace.visualstudio.com/items?itemName=TeamHub.teamhub) Extend VS Code with real-time collaborative superpowers
- [Kubernetes (Microsoft)](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
- [Docker (Microsoft)](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Bridge to Kubernetes](https://marketplace.visualstudio.com/items?itemName=mindaro.mindaro)
- [Gitpod](https://marketplace.visualstudio.com/items?itemName=gitpod.gitpod-desktop)
- [mirrord](https://marketplace.visualstudio.com/items?itemName=MetalBear.mirrord)
- [MongoDB for VS Code](https://marketplace.visualstudio.com/items?itemName=mongodb.mongodb-vscode)
- [Azure Devops Pull Requests](https://marketplace.visualstudio.com/items?itemName=ankitbko.vscode-pull-request-azdo)
- [Azure Repos](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-repos)
- [Argutec Azure Repos](https://marketplace.visualstudio.com/items?itemName=argutec.argutec-azure-repos)
- [Azure Pipelines](https://marketplace.visualstudio.com/items?itemName=ms-azure-devops.azure-pipelines)
- [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
- [Azure Resources](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureresourcegroups)
- [Azure Databases](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-cosmosdb)
- [Azure Storage](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurestorage)
- [Azure DevOps Snippets](https://marketplace.visualstudio.com/items?itemName=DamienAicheh.azure-devops-snippets)

My VSCode's user settings.json:

```json
{
    "editor.renderWhitespace": "all",
    "markdown.extension.list.indentationSize": "inherit",
    "markdown.extension.tableFormatter.enabled": true,
    "markdown.extension.tableFormatter.normalizeIndentation": true,
    "markdown.extension.toc.levels": "2..6",
    "markdown.extension.completion.respectVscodeSearchExclude": false,
    "markdown.extension.toc.slugifyMode": "azureDevops",
    "markdown.extension.toc.orderedList": true,
    "markdown.extension.math.enabled": false,
    "markdown.math.enabled": false,
    "editor.minimap.enabled": false,
    "editor.detectIndentation": false,
    "editor.tabSize": 4,
    "terminal.integrated.detectLocale": "on",
    "terminal.integrated.defaultProfile.osx": "pwsh",
    "editor.bracketPairColorization.enabled": true,
    "editor.guides.bracketPairs": "active",
    "powerShellUniversal.samplesDirectory": "undefined",
    "team.showWelcomeMessage": false,
    "azdoPullRequests.orgUrl": "https://dev.azure.com/EnterpriseDev",
    "azdoPullRequests.projectName": "App-Core",
    "[markdown]": {
        "editor.defaultFormatter": "darkriszty.markdown-table-prettify"
    },
    "markdownlint.config": {
        "default": true,
        "MD013": false,
        "MD003": { "style": "atx" },
        "MD007": { "indent": 4 },
        "MD033": false,
        "MD034": false,
        "editor.someSetting": true,
        "markdownlint.focusMode": true,
        "no-hard-tabs": false
    },
    "workbench.settings.useSplitJSON": true,
    "markdown.extension.toc.omittedFromToc": {
    },
    "files.autoSave": "afterDelay",
    "editor.language.brackets": [
    ],
    "GitLive.Issue tracker integration": "Disabled"
}
```

## References

- [External References](docs/references.md)
