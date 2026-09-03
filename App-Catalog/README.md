# Table of Contents

- [Enterprise App-Catalog Automation & Self-Service](#enterprise-app-catalog-automation---self-service)
- [Azure DevOps YAML Pipelines and Configuration Files](#azure-devops-yaml-pipelines-and-configuration-files)
- [Environments](#environments)
- [Requirements](#requirements)
    - [DNS Zones](#dns-zones)
    - [Environments and Permissions](#environments)
- [Test Users in App-Catalog](#test-users-in-app-catalog)
- [App Gateway Certificate](#app-gateway-certificate)
    - [Create Signed Wildcard Certificates in Production Environment](#create-signed-wildcard-certificates-in-production-environment)
- [Render terraform graphs with Graphviz](#render-terraform-graphs-with-graphviz)
- [RBAC](#rbac)
    - [Azure AD Custom Roles](#azure-ad-custom-roles)
    - [Azure ARM Custom Roles](#azure-arm-custom-roles)
    - [Azure AD Built-in Roles](#azure-ad-built-in-roles)
    - [Azure ARM Built-in Roles](#azure-arm-built-in-roles)
- [Known Issues and Solutions](#known-issues-and-solutions)
- [Improvements and Ideas](#improvements-and-ideas)
- [API Security and OAuth 2 in AAD - Microsoft APIs - Securing APIs and Authentication Flow](#api-security-and-oauth-2-in-aad---microsoft-apis---securing-apis-and-authentication-flow)
- [References](#references)

## Enterprise App-Catalog Automation & Self-Service

This repo contains two **Azure DevOps IaC pipelines** that deploy, update and destroy **Enterprise App-Catalog** on Azure with Azure DevOps and Terraform.

Environments are automatically created, updated and destroyed via Azure DevOps Pipelines. These pipelines might require [approvals](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals) in order to accept or reject changes. A [GitOps pattern](https://developers.redhat.com/articles/2022/07/20/git-workflows-best-practices-gitops-deployments) (the correct way of doing DevOps) with Terraform is the approach being used here. Terraform is an Infrastructure as Code solution (IaC).

- **Terraform is declarative and idempotent.**
- **GitOps:** Trunk-based development model in configuration repositories (**main** and **develop** branches on this repo)

An [immutable infrastructure](https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure) is another infrastructure paradigm in which servers are never modified after they’re deployed. If something needs to be updated, fixed, or modified in any way, new servers built from a common image with the appropriate changes are provisioned to replace the old ones. After they’re validated, they’re put into use and the old ones are decommissioned.

The benefits of an immutable infrastructure include more consistency and reliability in your infrastructure and a simpler, more predictable deployment process. It mitigates or entirely prevents issues that are common in mutable infrastructures, like configuration drift and snowflake servers. However, using it efficiently often includes comprehensive deployment automation, fast server provisioning in a cloud computing environment, and solutions for handling stateful or ephemeral data like logs.

- Normal Flow:      Develop ---> Deploy    ---> Configure
- Immutable Flow:   Develop ---> Configure ---> Deploy

## Azure DevOps YAML Pipelines and Configuration Files

Azure DevOps YAML Pipelines:

- [01-terraform-provision-catalog3-pipeline.yml](01-terraform-provision-catalog3-pipeline.yml): Pipeline with Terraform Create
- [02-terraform-destroy-catalog3-pipeline.yml](02-terraform-destroy-catalog3-pipeline.yml): Pipeline with Terraform Destroy

Configuration files of this repo's pipelines:

- [configuration/developbranch-service-connections.yml](configuration/developbranch-service-connections.yml): Azure DevOps Service Connection used on this repo develop branch (GitOps pattern with a trunk branch model)
- [configuration/mainbranch-service-connections.yml](configuration/mainbranch-service-connections.yml): Azure DevOps Service Connection used on this repo main branch (GitOps pattern with a trunk branch model)
- [configuration/shared-azure-devops-pipeline-vars.yml](configuration/shared-azure-devops-pipeline-vars.yml): Shared variables among both develop and main branches.
- [configuration/variable-group-with-secrets.yml](configuration/variable-group-with-secrets.yml): Azure DevOps Variable Groups with secrets to be injected in Terraform code and pulled from Azure Key Vaults.

## Environments

- **DEV** environment is used for developer’s tasks, like merging commits in the first place, running unit tests. Dev environment is usually not guaranteed to be stable. The operation can be disrupted by commit, and it doesn’t do harm for the whole company. DEV environment is usually hooked to some CI/CD system. When developers do code merge, the build is automatically triggered, and application code is automatically redeployed to Dev.
- **QA** is for testing by Quality Assurance team, both manual and automated, including running automated integration tests. It’s considered to be more stable than Dev, because code doesn't change so often on every merge, as in Dev.
  So, developers cannot disrupt ongoing work of QA engineers by “risky” change.
- **UAT (User Acceptance Testing)** environment is for pre-release testing, the environment in which user acceptance testing is performed. Note the emphasis on user - your QA testing is different, UAT is a chance for actual users (or at least your training team, sales, support staff etc...) to try out new features and evaluate the software before it is deployed to their production systems. It is used by QA engineers, business analysts, product owners, for verifying functional requirements. UAT is required to be stable, because it’s used not only by developers but also by business users , who serve as “functional testers”. It also can be used as demo environment for showing new features to the customers. What this means exactly will depend on your processes:
    - UAT (the environment) might be "level" with production, and is essentially a sandbox for users to try new features with.
    - UAT (the environment) might be "ahead" of production, so that new features are not deployed to production until they have been evaluated. (I'm not keen on this approach as it necessarily means you have longer lead times).
    - It you have a multi-tenant system you might not even need a UAT environment, instead you could choose to have users evaluate new features in production systems by making use of feature flags.
- **Staging aka Pre-production (PRE)** environment is often set up with a copy of production data, sometimes sanitized. Many organizations regularly "refresh" their staging database from a production snapshot. The primary focus is to ensure that the application will work in production the same way it worked in UAT. Instead of setting up new data, testers will search the database for profiles and products that match an essential set of test cases. Often the "real" data have quirks in them that give rise to unexpected edge cases that were missed during UAT. Also, any data migration testing would need to take place in the staging environment.
- **PRO** is production environment, serving primary business purpose. Access of developers to it usually limited only to perform technical support duties.

Sometimes, there are more intermediate test environments, called IT, SIT (for integration testing ), or Regression (pre-release regression testing). From testing perspective, these environments ordered in such way, so application migrates to the next environment only after it is passed all tests at previous stage.

**Example:** DEV (dev tests passed) -> deploy to QA (QA integration tests passed) - > deploy to UAT (UAT acceptance tests passed) -> deploy to PRE aka STAGING (Staging tests passed) -> deploy to PRO

In terms of Continuous Deployment / Continuous Delivery, the staging environment is used to test software in a "production-like" environment, as its likely that developers will be working in an environment with significant differences to production (e.g. no load balancing, a smaller dataset etc..).

## Requirements

### DNS Zones

Take into account a new entry within the same DNS Zone should not have conflicts with an existing one (i.e. when the same client name is found in both AppAnalysis & App-Catalog platforms).

| DNS Zone (subdomain of enterprise.com) | Environments          | Example                    | [Added to AAD Custom Domain Names?](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Domains) |
|:-----------------------------------|:----------------------|:---------------------------|:------------------------------------------------------------------------------------------------------------------------:|
| ~~eng.enterprise.com~~                 | ~~Dev, QA, UAT, Pre~~ | ~~catadev.eng.enterprise.com~~ |                                                 ~~**Yes** (test users)~~                                                 |
| dev.enterprise.com                     | Dev                   | catadev.dev.enterprise.com     |                                                            No                                                            |
| qa.enterprise.com                      | QA                    | catadev.qa.enterprise.com      |                                                            No                                                            |
| uat.enterprise.com                     | UAT                   | catadev.uat.enterprise.com     |                                                            No                                                            |
| pre.enterprise.com                     | Pre                   | catadev.pre.enterprise.com     |                                                            No                                                            |
| apps.enterprise.com                    | Pro                   | cata.apps.enterprise.com       |                                                            No                                                            |

### Environments and Permissions

1. Azure Subscriptions (orientative):
    1. Azure Subscription with Terraform TFSTATE and Azure Key Vault with Secrets: **Enterprise DevOps Subscription**
    2. Azure Subscription with Azure Key Vault with Wildcard Certificates: **Enterprise Infrastructure Subscription**
    3. Azure Subscription with **DEV** deployment target: **Enterprise DevTest Subscription**
    4. Azure Subscription with **QA** deployment target: **Enterprise DevTest Subscription**
    5. Azure Subscription with **UAT** deployment target: **Enterprise DevTest Subscription**
    6. Azure Subscription with **PRE** deployment target: **Enterprise DevTest Subscription**
    7. Azure Subscription with **PRO** deployment target: **Enterprise DevTest Subscription**
2. [Azure DevOps Terraform Extension: Terraform by Microsoft DevLabs](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
3. Azure DevOps Environments: Make sure the following environments are defined in [Azure DevOps environments](https://dev.azure.com/EnterpriseDev/App-Catalog/_environments):
    - dev
    - qa
    - uat
    - pre
    - pro
4. **sp-app-analysis-enterprise-dev** Service Principal leveraged by this pipeline with these settings:
    - API Permissions:
        - User.Read - Delegated
        - One of the following application roles (Microsoft Graph - Application permissions):
            - **Application.ReadWrite.All** or **Directory.ReadWrite.All**: Otherwise this pipeline won't be able to run [terraform-manifests/08-app-register.tf](terraform-manifests/08-app-register.tf). See [this reference](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application).
            - Click on **"Grant admin consent for enterprise.com"**
    - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
5. [AAD Management Scope - Azure AD Roles - Application administrator | Asignments](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/00000000-0000-0000-0000-000000000000/roleId/00000000-0000-0000-0000-000000000000/roleTemplateId/00000000-0000-0000-0000-000000000000/roleName/Application%20administrator/isRoleCustom~/false/resourceScopeId/%2F/resourceId/00000000-0000-0000-0000-000000000000)
    - **sp-app-analysis-enterprise-dev**
6. [AAD Management Scope - Azure AD Roles - Attribute assignment administrator | Asignments](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/00000000-0000-0000-0000-000000000000/roleId/00000000-0000-0000-0000-000000000000/roleTemplateId/00000000-0000-0000-0000-000000000000/roleName/Attribute%20assignment%20administrator/isRoleCustom~/false/resourceScopeId/%2F00000000-0000-0000-0000-000000000000/resourceId/00000000-0000-0000-0000-000000000000):
    - **sp-app-analysis-enterprise-dev**
7. [AAD Management Scope - Azure AD Roles - User Administrator | Asignments](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/roleObjectId/00000000-0000-0000-0000-000000000000/roleId/00000000-0000-0000-0000-000000000000/roleTemplateId/00000000-0000-0000-0000-000000000000/roleName/User%20administrator/isRoleCustom~/false/resourceScopeId/%2F/resourceId/00000000-0000-0000-0000-000000000000):
    - **sp-app-analysis-enterprise-dev**
        - Type: Service Principal
        - Scope: Directory
        - Membership: Directory
        - State: Assigned
        - End time: Permanent
8. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope):
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (Contributor role is not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - **sp-app-analysis-enterprise-dev**  (it needs to assign roles in Azure RBAC)
            - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                - Dedicated administrators group for this Azure Subscription
                - Conditon: None
        - **"Key Vault Administrator"**:
            - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                - Dedicated administrators group for this Azure Subscription
                - Required to see and manage key vault secrets and certs
                - Conditon: None
        - **"Key Vault Secrets Officer"**:
            - **sp-app-analysis-enterprise-dev** - Conditon: None
            - Description: Azure DevOps EnterpriseDev / App-Catalog / Settings / Service connections: svccon-app-analysis-dev
        - **"Key Vault Certificates Officer"**:
            - **sp-app-analysis-enterprise-dev** - Conditon: None
            - Description: Azure DevOps EnterpriseDev / App-Catalog / Settings / Service connections: svccon-app-analysis-dev
9. [kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/overview) within [Enterprise Infrastructure Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Key Vault Scope):
    - Access Control (IAM) -> Role Assignments:
        - **"Key Vault Administrator"**:
            - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                - Dedicated administrators group for this Azure Subscription
                - Required to see and manage key vault secrets and certs
                - Conditon: None
        - **"Key Vault Secrets Officer"**:
            - **sp-app-analysis-enterprise-dev** - Conditon: None
        - **"Key Vault Certificates Officer"**:
            - **sp-app-analysis-enterprise-dev** - Conditon: None
10. [svccon-app-analysis-devops Service Connection](https://dev.azure.com/EnterpriseDev/App-Catalog/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: 00000000-0000-0000-0000-000000000000  (Enterprise DevOps Subscription)
    - Subscription Name: **Enterprise DevOps Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-app-analysis-enterprise-dev)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-app-analysis-devops**
    - Description: Connects to Enterprise DevOps Subscription via sp-app-analysis-enterprise-dev
    - Grant access permissions to all pipelines: enabled
11. **Permissions on each deployment target subscription**, i.e. DEV environment assigned to **Enterprise DevTest Subscription** and reached via a [svccon-app-analysis-dev Service Connection](https://dev.azure.com/EnterpriseDev/App-Catalog/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: 00000000-0000-0000-0000-000000000000  (Enterprise DevTest Subscription)
    - Subscription Name: **Enterprise DevTest Subscription**
    - Service Principal Id: 00000000-0000-0000-0000-000000000000   (sp-app-analysis-enterprise-dev)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-app-analysis-dev**
    - Description: Connects to Enterprise DevTest Subscription via sp-app-analysis-enterprise-dev, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**
12. [svccon-wildcard-certificates Service Connection](https://dev.azure.com/EnterpriseDev/App-Catalog/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: 00000000-0000-0000-0000-000000000000  (Enterprise Infrastructure Subscription)
    - Subscription Name: **Enterprise Infrastructure Subscription**
    - Service Principal Id: 00000000-0000-0000-0000-000000000000   (sp-app-analysis-enterprise-dev)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-wildcard-certificates**
    - Description: connects via sp-app-analysis-enterprise-dev to key vault with wildcard certs located in Enterprise Infrastructure Subscription - CertificatesResourceGroup
    - Grant access permissions to all pipelines: disabled
13. Azure [kv-azuredevops-library2](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azuredevops-pro/providers/Microsoft.KeyVault/vaults/kv-azuredevops-library2/secrets) key vault:
    - Access Policies:
        - Azure role-based access control: **enabled**
    - Access Control (IAM): Nothing to do here since these permissions are inherited from the Subscription Scope.

    | Variable in Azure KeyVault (orientative)                                                                                                              | Git Branch     | Env (orientative)                                                        | Type        |  MongoDB Org  | Azure Key Vault         | Imported in Azure DevOps Library? | Variable in [**terraform-apply.yml**](templates/terraform-apply.yml) & 02-variables.tf | Variable in 09-app-service.tf   | Variable in 10-application-gateway.tf | Variable in 11-key-vault.tf          | Variable in provider.tf              |
    |-------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|--------------------------------------------------------------------------|-------------|:-------------:|-------------------------|:---------------------------------:|----------------------------------------------------------------------------------------|---------------------------------|---------------------------------------|--------------------------------------|--------------------------------------|
    | cert-wildcard-eng-enterprise-com00000000-0000-0000-0000-000000000000 (use this one!)<br><br>cert-wildcard-enterprise-eng (exported cert)                      | main           | Dev, QA, UAT, Pre                                                        | Certificate |       -       | kv-azuredevops-library2 |                Yes                | secret_appGatewayListenerSecure                                                        |                                 | App-Catalog_agw.ssl_certificate.data   | enterprise_wildcard.certificate.contents |                                      |
    | cert-wildcard-deng-enterprise-com00000000-0000-0000-0000-000000000000 (use this one!)<br><br>cert-wildcard-enterprise-deng (exported cert)                    | develop        | DDev, DQA, DUAT, DPre                                                    | Certificate |       -       | kv-azuredevops-library2 |                Yes                | secret_appGatewayListenerSecure                                                        |                                 | App-Catalog_agw.ssl_certificate.data   | enterprise_wildcard.certificate.contents |                                      |
    | cert-wildcard-apps-enterprise-com00000000-0000-0000-0000-000000000000 (use this one!)<br><br>cert-wildcard-enterprise-apps (exported cert)                    | main           | Pro                                                                      | Certificate |       -       | kv-azuredevops-library2 |                Yes                | secret_appGatewayListenerSecure                                                        |                                 | App-Catalog_agw.ssl_certificate.data   | enterprise_wildcard.certificate.contents |                                      |
    | docker-registry-password-appanalysispro                                                                                                                 | main           | Dev, QA, UAT, Pre, Pro                                                   | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_docker_registry_server_password                                                 | DOCKER_REGISTRY_SERVER_PASSWORD |                                       |                                      |                                      |
    | app-analysis-config-key-myclient-dev                                                                                                                     | main           | Dev, QA, UAT, Pre, Pro                                                   | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_app_analysis_config_key                                                            | config_key & enterprise_key         |                                       |                                      |                                      |
    | mongodb-atlas-enterprisedevtest-public-key                                                                                                                | main           | Dev                                                                      | Secret      | EnterpriseDEVTEST | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_public_key                                                        |                                 |                                       |                                      | var.secret_mongodb_atlas_public_key  |
    | mongodb-atlas-enterprisedevtest-private-key                                                                                                               | main           | Dev                                                                      | Secret      | EnterpriseDEVTEST | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_private_key                                                       |                                 |                                       |                                      | var.secret_mongodb_atlas_private_key |
    | mongodb-atlas-enterprisedevtest-dbuser-password                                                                                                           | main           | Dev                                                                      | Secret      | EnterpriseDEVTEST | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_dbadmin_password                                                  |                                 |                                       |                                      |                                      |
    | mongodb-atlas-enterprisedevtest-dbuser-password                                                                                                           | main           | Dev                                                                      | Secret      | EnterpriseDEVTEST | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_dbuser_password                                                   |                                 |                                       |                                      |                                      |
    | mongodb-atlas-enterprise-public-key                                                                                                                       | main           | Pro, Dem, Res                                                            | Secret      |    Enterprise     | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_public_key                                                        |                                 |                                       | var.secret_mongodb_atlas_public_key  |                                      |
    | mongodb-atlas-enterprise-private-key                                                                                                                      | main           | Pro, Dem, Res                                                            | Secret      |    Enterprise     | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_private_key                                                       |                                 |                                       | var.secret_mongodb_atlas_private_key |                                      |
    | mongodb-atlas-enterprise-dbadmin-password                                                                                                                 | main           | Pro, Dem, Res                                                            | Secret      |    Enterprise     | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_dbadmin_password                                                  |                                 |                                       |                                      |                                      |
    | mongodb-atlas-enterprise-dbuser-password                                                                                                                  | main           | Dem, Pro, Res                                                            | Secret      |    Enterprise     | kv-azuredevops-library2 |                Yes                | secret_mongodb_atlas_dbuser_password                                                   |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-host <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) or from Azure Portal to Azure KV)     | main & develop | Europe main branch: Dev, QA, UAT, Pre<br>Europe develop branch: Pro, Res | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_host_europe                                                     |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-client-certificate  <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)           | main & develop | Europe main branch: Dev, QA, UAT, Pre<br>Europe develop branch: Pro, Res | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_certificate_europe                                       |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-client-key          <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)           | main & develop | Europe main branch: Dev, QA, UAT, Pre<br>Europe develop branch: Pro, Res | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_key_europe                                               |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-cluster-ca-certificate <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)        | main & develop | Europe main branch: Dev, QA, UAT, Pre<br>Europe develop branch: Pro, Res | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_cluster_ca_certificate_europe                                   |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-host-usa <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) or from Azure Portal to Azure KV) | main & develop | USA main branch: Dev, QA, UAT, Pre<br>USA develop branch: Pro, Res       | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_host_unitedstates                                               |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-client-certificate-usa <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)        | main & develop | USA main branch: Dev, QA, UAT, Pre<br>USA develop branch: Pro, Res       | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_certificate_unitedstates                                 |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-client-key-usa   <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)              | main & develop | USA main branch: Dev, QA, UAT, Pre<br>USA develop branch: Pro, Res       | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_key_unitedstates                                         |                                 |                                       |                                      |                                      |
    | aks-eng-kube-config-cluster-ca-certificate-usa   <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)  | main & develop | USA main branch: Dev, QA, UAT, Pre<br>USA develop branch: Pro, Res       | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_cluster_ca_certificate_unitedstates                             |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-host <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) or from Azure Portal to Azure KV)     | main           | Pro, Res (Europe)                                                        | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_host_europe                                                     |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-client-certificate    <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)         | main           | Pro, Res (Europe)                                                        | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_certificate_europe                                       |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-client-key    <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)                 | main           | Pro, Res (Europe)                                                        | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_key_europe                                               |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-cluster-ca-certificate  <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)       | main           | Pro, Res (Europe)                                                        | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_cluster_ca_certificate_europe                                   |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-host-usa <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) or from Azure Portal to Azure KV) | main           | Pro, Res (USA)                                                           | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_host_unitedstates                                               |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-client-certificate-usa  <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)       | main           | Pro, Res (USA)                                                           | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_certificate_unitedstates                                 |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-client-key-usa     <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)            | main           | Pro, Res (USA)                                                           | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_client_key_unitedstates                                         |                                 |                                       |                                      |                                      |
    | aks-pro-kube-config-cluster-ca-certificate-usa  <br>(copied from [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) to Azure KV)   | main           | Pro, Res (USA)                                                           | Secret      |       -       | kv-azuredevops-library2 |                Yes                | secret_aks_kube_config_cluster_ca_certificate_unitedstates                             |                                 |                                       |                                      |                                      |

    | aks-eng: secret name in kv-azuredevops-library2 | Tip: copy this info on each secret Content type (optional)                                                            | Copied from                                                                           |
    |-------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
    | aks-eng-kube-config-client-certificate          | 1/4   aks-neeng: client-certificate-data in kubeconfig                                                                | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/)                      |
    | aks-eng-kube-config-client-key                  | 2/4   aks-neeng: client-key-data in kubeconfig                                                                        | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/)                      |
    | aks-eng-kube-config-cluster-ca-certificate      | 3/4   aks-neeng: certificate-authority-data in kubeconfig                                                             | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/)                      |
    | aks-eng-kube-config-host                        | 4/4   aks-neeng: AKS host ENG Europe Region. Example: rg-sharedinfra-aks-neeng-b360a135.hcp.northeurope.azmk8s.io:443 | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) or from Azure Portal |

    | aks-pro: secret name in kv-azuredevops-library2 | Tip: copy this info on each secret Content type (optional)                                                            | Copied from                                                                           |
    |-------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
    | aks-pro-kube-config-client-certificate          | 1/4   aks-nepro: client-certificate-data in kubeconfig                                                                | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/)                      |
    | aks-pro-kube-config-client-key                  | 2/4   aks-nepro: client-key-data in kubeconfig                                                                        | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/)                      |
    | aks-pro-kube-config-cluster-ca-certificate      | 3/4   aks-nepro: certificate-authority-data in kubeconfig                                                             | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/)                      |
    | aks-pro-kube-config-host                        | 4/4   aks-nepro: AKS host PRO Europe region. Example: rg-sharedinfra-aks-nepro-56ef6c7d.hcp.northeurope.azmk8s.io:443 | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) or from Azure Portal |

    | Service connection in Azure DevOps Shared-Infra project | Copied from                                                      |
    |---------------------------------------------------------|------------------------------------------------------------------|
    | aks-nepro                                               | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) |
    | aks-neeng                                               | [kubeconfig](https://devopscube.com/kubernetes-kubeconfig-file/) |

    **Tip**: use [this tool](https://www.tablesgenerator.com/) or [this other one](https://marketplace.visualstudio.com/items?itemName=csholmq.excel-to-markdown-table) to edit the above table.

14. Azure DevOps Pipeline Library:
    - [Secure files](https://dev.azure.com/EnterpriseDev/App-Catalog/_library?itemType=SecureFiles): Not used
    - [Variable groups](https://dev.azure.com/EnterpriseDev/App-Catalog/_library?itemType=VariableGroups):
        - Variable group name: **[DevOps-App-Catalog](https://dev.azure.com/EnterpriseDev/App-Catalog/_library?itemType=VariableGroups&view=VariableGroupView&variableGroupId=1&path=DevOps-App-Catalog)**:
            - Description: Variable group name used by App-Catalog Azure DevOps IaC Pipelines. Secrets and certificates are pulled from an Azure Key Vault setup here.
            - Link secrets from an Azure key vault as variables: **enabled**
            - Azure Subscription (Azure DevOps Service Connection): **[svccon-app-analysis-devops](https://dev.azure.com/EnterpriseDev/App-Catalog/_settings/adminservices)**
            - Key vault name **[kv-azuredevops-library2](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azuredevops-pro/providers/Microsoft.KeyVault/vaults/kv-azuredevops-library2/secrets)**.
            - Manual task: Make sure the mentioned key vault is setup with **"Azure role-based access control"** instead of the default "Vault access policy".
            - Manual task: Choose secrets to be included from the azure key vault into this variable group. These variables are pulled by the pipeline.
            - Link secrets from an Azure key vault as variables: **enabled**
            - Click on **Save**
        - Variable group name: **Wildcard-Certificates**:
            - Description: Key Vault with '*.enterprise' and '*.eng.enterprise.com' signed wildcard certificates.
            - Link secrets from an Azure key vault as variables: **enabled**
            - Azure Subscription (Azure DevOps Service Connection): **[svccon-wildcard-certificates](https://dev.azure.com/EnterpriseDev/App-Catalog/_settings/adminservices)**
            - Key vault name **[kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/overview)**.
            - Manual task: Make sure the mentioned key vault is setup with **"Azure role-based access control"** instead of the default "Vault access policy".
            - Manual task: Choose secrets to be included from the azure key vault into this variable group. These variables are pulled by the pipeline.
            - Link secrets from an Azure key vault as variables: **enabled**
            - Click on **Save**
15. **App Gateway Certificate** to be imported 1st into [kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/overview) and secondly into [Wildcard-Certifificates](https://dev.azure.com/EnterpriseDev/App-Catalog/_library?itemType=VariableGroups). Check the following section.
16. MongoDB Atlas:

    - Setup an API Key with the following permissions in: [MongoDB Atlas](https://cloud.mongodb.com/) -> ['EnterpriseDevTest' Organization Settings](https://cloud.mongodb.com/v2#/org/000000000000000000000000/settings/general) -> [Organization Access Manager - API Keys](https://cloud.mongodb.com/v2#/org/000000000000000000000000/access/apiKeys):
        - Roles/Permissions:
            - Organization Owner
            - Organization Project Creator
        - API Access List:
            - 127.0.0.1/0   (allow access from everywhere, Azure DevOps included)

    - **Review/Configure API Access Lists within your MongoDB Atlas Organization:**
        - Check this [ref1](https://www.mongodb.com/docs/atlas/configure-api-access/) and [ref2](https://www.mongodb.com/docs/atlas/configure-api-access/#std-label-create-org-api-key).
        - Check existing API Keys already setup in your MongoDB Atlas Organization:

            ```bash
                curl --user "{public_key}:{private_key}" --digest \
                --header "Accept: application/json" \
                --header "Content-Type: application/json" \
                --include \
                --request GET "https://cloud.mongodb.com/api/atlas/v1.0/orgs/{mongodb_org}}/apiKeys?pretty=true"
            ```

        - Check existing IP Access Lists already setup in your API Key:

            ```bash
                curl --user "{public_key}:{private_key}" --digest \
                --header "Accept: application/json" \
                --header "Content-Type: application/json" \
                --include \
                --request GET "https://cloud.mongodb.com/api/atlas/v1.0/orgs/{mongodb_org}}/apiKeys/{api_key}/accessList?pretty=true"
            ```

17. **Azure AD integration with MongoDB Cloud (currently not implemented)**:
    - Azure AD -> Enterprise Applications -> MongoDB Cloud
    - [docs.microsoft.com:  Tutorial: Azure AD SSO integration with MongoDB Cloud 🌟](https://docs.microsoft.com/en-us/azure/active-directory/saas-apps/mongodb-cloud-tutorial)
    - [mongodb.com: Configure Federated Authentication from Azure AD](https://www.mongodb.com/docs/atlas/security/federated-auth-azure-ad/) Atlas doesn't support single sign-on integration for database users.
    - [mongodb.com: Configure User Authentication and Authorization with Azure AD Domain Services](https://www.mongodb.com/docs/atlas/security-ldaps-azure/#std-label-security-ldaps-azure)
18. Once infra environments have been created by this terraform based pipeline - Go To Azure Portal - DNS Zones - "enterprise.com" - **Create DNS record sets of type NS (1 per environment)**:
    - dev : Add NS (Name Servers) already assigned to "dev.enterprise.com" DNS Zones created by Terraform
    - qa : Add NS (Name Servers) already assigned to "qa.enterprise.com" DNS Zones created by Terraform
    - uat : Add NS (Name Servers) already assigned to "uat.enterprise.com" DNS Zones created by Terraform
    - pre : Add NS (Name Servers) already assigned to "pre.enterprise.com" DNS Zones created by Terraform
    - apps : Add NS (Name Servers) already assigned to "apps.enterprise.com" DNS Zones created by Terraform

## Test Users in App-Catalog

User Identity Management in App-Catalog is not centralized on AAD but on each instance of MongoDB Atlas. In consequence, test users created on AAD via terraform are currently not integrated on App-Catalog.

## App Gateway Certificate

### Create Signed Wildcard Certificates in Production Environment

1. Purchase a production certificate: [Start a certificate order](https://docs.microsoft.com/en-us/azure/app-service/configure-ssl-certificate?tabs=apex%2Cportal#start-certificate-order) - [Purchase/Create Wildcard Certificate](https://portal.azure.com/#create/Microsoft.SSL).
2. Import the generated and signed certificate into [kv-wildcards-enterprise-com](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/CertificatesResourceGroup/providers/Microsoft.KeyVault/vaults/kv-wildcards-enterprise-com/overview) and [Azure DevOps Pipeline Library - Variable Group - Wildcard-Certifificates](https://dev.azure.com/EnterpriseDev/App-Catalog/_library?itemType=VariableGroups).

| Signed Wildcard Certificate           |                               Already Purchased                               | Environments          | .pfx cert file exported from key vault secret                                                         | Cert name in Azure KeyVault manually imported from .pfx file | Cert name in [**terraform-apply.yml**](templates/terraform-apply.yml) |
|:--------------------------------------|:-----------------------------------------------------------------------------:|:----------------------|:------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------|:----------------------------------------------------------------------|
| *.eng.enterprise.com (currently not used) |                                      Yes                                      | ~~Dev, QA, UAT, Pre~~ | kv-wildcards-enterprise-com-cert-wildcard-eng-enterprise-com00000000-0000-0000-0000-000000000000-20220908.pfx | cert-wildcard-enterprise-eng                                     | secret_appGatewayListenerSecure                                       |
| *.dev.enterprise.com                      | No ([self-signed with this script](scripts/generate-wildcard-certificate.sh)) | Dev                   | NA                                                                                                    | cert-wildcard-enterprise-dev                                     | secret_appGatewayListenerSecure                                       |
| *.qa.enterprise.com                       | No ([self-signed with this script](scripts/generate-wildcard-certificate.sh)) | QA                    | NA                                                                                                    | cert-wildcard-enterprise-qa                                      | secret_appGatewayListenerSecure                                       |
| *.uat.enterprise.com                      | No ([self-signed with this script](scripts/generate-wildcard-certificate.sh)) | UAT                   | NA                                                                                                    | cert-wildcard-enterprise-uat                                     | secret_appGatewayListenerSecure                                       |
| *.pre.enterprise.com                      | No ([self-signed with this script](scripts/generate-wildcard-certificate.sh)) | Pre                   | NA                                                                                                    | cert-wildcard-enterprise-pre                                     | secret_appGatewayListenerSecure                                       |
| *.apps.enterprise.com                     | No ([self-signed with this script](scripts/generate-wildcard-certificate.sh)) | Pro                   | NA                                                                                                    | cert-wildcard-enterprise-pro                                     | secret_appGatewayListenerSecure                                       |

## Render terraform graphs with Graphviz

Grab the outcome of **terraform graph** from Azure DevOps Pipeline Logs and render a graph with tools like [GraphViz](https://graphviz.org/) to visualize our terraform settings:

```bash
brew install graphviz
dot -Tpng terraform_graph_app_analysis.out -o graph.png
```

Similarly, we can also use the online [Graphviz website](https://dreampuf.github.io/GraphvizOnline/) to get a visual representation of the terraform configurations.

[Reference](https://blog.knoldus.com/how-to-use-terraform-graph-to-visualize-your-execution-plan/)

## RBAC

### Azure AD Custom Roles

- [Terraform AAD Example Usage (Custom Directory Role within Azure Active Directory)](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/custom_directory_role)

### Azure ARM Custom Roles

- [Azure custom roles 🌟](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Terraform Example Usage (Custom Role & Service Principal)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment#example-usage-custom-role--service-principal)
- [Terraform Example Usage (Custom Role & User)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment#example-usage-custom-role--user)
- [Terraform Example Usage (Custom Role & Management Group)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment#example-usage-custom-role--management-group)

### Azure AD Built-in Roles

- [Terraform AD Example Usage (Built-in Directory Role within Azure Active Directory)](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) Manages a Directory Role within Azure Active Directory. Directory Roles are also known as Administrator Roles.

### Azure ARM Built-in Roles

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

- AKS:
    - Azure Kubernetes Fleet Manager Contributor Role - Grants access to read and write Azure Kubernetes Fleet Manager clusters
    - Azure Kubernetes Fleet Manager RBAC Admin - This role grants admin access - provides write permissions on most objects within a a namespace, with the exception of ResourceQuota object and the namespace object itself. Applying this role at cluster scope will give access across all namespaces.
    - Azure Kubernetes Fleet Manager RBAC Cluster Admin - Lets you manage all resources in the fleet manager cluster.
    - Azure Kubernetes Fleet Manager RBAC Reader - Allows read-only access to see most objects in a namespace. It does not allow viewing roles or role bindings. This role does not allow viewing Secrets, since reading the contents of Secrets enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount in the namespace (a form of privilege escalation). Applying this role at cluster scope will give access across all namespaces.
    - Azure Kubernetes Fleet Manager RBAC Writer - Allows read/write access to most objects in a namespace.This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing Secrets as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace. Applying this role at cluster scope will give access across all namespaces.
    - Azure Kubernetes Service Cluster Admin Role - List cluster admin credential action.
    - Azure Kubernetes Service Cluster User Role - List cluster user credential action.
    - Azure Kubernetes Service Contributor Role - Grants access to read and write Azure Kubernetes Service clusters
    - Azure Kubernetes Service Policy Add-on Deployment - Deploy the Azure Policy add-on on Azure Kubernetes Service clusters
    - Azure Kubernetes Service RBAC Admin - Lets you manage all resources under cluster/namespace, except update or delete resource quotas and namespaces.
    - Azure Kubernetes Service RBAC Cluster Admin - Lets you manage all resources in the cluster.
    - Azure Kubernetes Service RBAC Reader - Allows read-only access to see most objects in a namespace. It does not allow viewing roles or role bindings. This role does not allow viewing Secrets, since reading the contents of Secrets enables access to ServiceAccount credentials in the namespace, which would allow API access as any ServiceAccount in the namespace (a form of privilege escalation). Applying this role at cluster scope will give access across all namespaces.
    - Azure Kubernetes Service RBAC Writer - Allows read/write access to most objects in a namespace.This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing Secrets and running Pods as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace. Applying this role at cluster scope will give access across all namespaces.
    - Kubernetes Cluster - Azure Arc Onboarding - Role definition to authorize any user/service to create connectedClusters resource
    - Kubernetes Extension Contributor - Can create, update, get, list and delete Kubernetes Extensions, and get extension async operations
    - Kubernetes Namespace User - Allows a user to read namespace resources and retrieve kubeconfig for the cluster
    - Microsoft.Kubernetes connected cluster role - Microsoft.Kubernetes connected cluster role.

## Known Issues and Solutions

- Failed to link certificate with the selected Key Vault. Check below errors for more detail: The parameter KeyVaultCsmId has an invalid value
    - https://stackoverflow.com/questions/65781652/error-the-parameter-keyvaultcsmid-has-an-invalid-value-while-adding-app-servic
- ```Error: error creating Project: POST https://cloud.mongodb.com/api/atlas/v1.0/groups: 403 (request "IP_ADDRESS_NOT_ON_ACCESS_LIST") IP address 127.0.0.1 is not allowed to access this resource.```
    - [Atlas API is not accepting request from terraform cloud IaC runners](https://www.mongodb.com/community/forums/t/atlas-api-is-not-accepting-request-from-terraform-cloud-iac-runners/98688/10)

## Improvements and Ideas

- Replace Key Vault Secrets with RBAC settings (when possible).
- [Conditions: Run if the branch is main](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/conditions)
- [postman.com: API Security Testing with Pynt](https://www.postman.com/pynt-io/workspace/pynt/overview) - [pynt.io](https://www.pynt.io/)
- Add a flag to each deployment settings in order to include a dedicated App Gateway instance (i.e in Novartis)

## API Security and OAuth 2 in AAD - Microsoft APIs - Securing APIs and Authentication Flow

- [API Security and OAuth 2.0 in AAD. Microsoft APIs, Securing APIs & Authentication Flow](docs/aad-api-security-oauth2.md)

## References

- [External References](docs/references.md)