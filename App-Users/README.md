# Table of Contents

1. [Enterprise App-Core-Users Automation and Self-Service](#enterprise-app-core-users-automation-and-self-service)
2. [Azure DevOps YAML Pipelines and Configuration Files](#azure-devops-yaml-pipelines-and-configuration-files)
3. [Azure Resource Groups with Terraform State Files](#azure-resource-groups-with-terraform-state-files)
4. [Environments](#environments)
5. [YAML files with lists of Users to be provisioned in Enterprise Azure AD](#yaml-files-with-lists-of-users-to-be-provisioned-in-enterprise-azure-ad)
   1. [Matrix table with Environment Names in YAML files](#matrix-table-with-environment-names-in-yaml-files)
   2. [Key Value pairs Reference in YAML files with Internal Users](#key-value-pairs-reference-in-yaml-files-with-internal-users)
   3. [Key Value pairs Reference in YAML files with External Users](#key-value-pairs-reference-in-yaml-files-with-external-users)
   4. [Key Value pairs Reference in YAML files with Manually Provisioned Internal Users](#key-value-pairs-reference-in-yaml-files-with-manually-provisioned-internal-users)
   5. [Example of a YAML file with an empty list of users](#example-of-a-yaml-file-with-an-empty-list-of-users)
   6. [Example of a YAML file with a list of Internal Users](#example-of-a-yaml-file-with-a-list-of-internal-users)
   7. [Example of a YAML file with a list of External Users. AzureAD B2B external user (guest) invitations](#example-of-a-yaml-file-with-a-list-of-external-users-azuread-b2b-external-user-guest-invitations)
   8. [Example of a YAML file with a list of Manually Provisioned Internal Users](#example-of-a-yaml-file-with-a-list-of-manually-provisioned-internal-users)
6. [Requirements and Permissions](#requirements-and-permissions)
   1. [Matrix table with required Service Principals and Azure DevOps Service Connections](#matrix-table-with-required-service-principals-and-azure-devops-service-connections)
   2. [Matrix table with required Service Users and Azure DevOps Service Connections](#matrix-table-with-required-service-users-and-azure-devops-service-connections)
   3. [List of permissions](#list-of-permissions)
7. [FAQ](#faq)
   1. [Render terraform graphs with Graphviz](#render-terraform-graphs-with-graphviz)
   2. [How to rollback in a GitOps flow with Azure DevOps pipelines](#how-to-rollback-in-a-gitops-flow-with-azure-devops-pipelines)
8. [References](#references)
   1. [YAML](#azure-devops-yaml-pipelines-and-configuration-files)
   2. [Azure AD](#yaml-files-with-lists-of-users-to-be-provisioned-in-enterprise-azure-ad)
   3. [Terraform](#azure-resource-groups-with-terraform-state-files)
   4. [Git](#how-to-rollback-in-a-gitops-flow-with-azure-devops-pipelines)

## Enterprise App-Core-Users Automation and Self-Service

This repo developed by the [Platform Engineering](https://softwareengineeringdaily.com/2020/02/13/setting-the-stage-for-platform-engineerin) team contains two **Azure DevOps IaC pipelines** that deploy, update and destroy the **Provisioning of final users on Enterprise App-Core**. These Terraform based automated Azure DevOps pipelines **run in parallel**.

Internal and External users accounts are automatically created, updated and destroyed via Azure DevOps Pipelines. These pipelines might require [approvals](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/approvals) in order to accept or reject changes. A [GitOps pattern](https://developers.redhat.com/articles/2022/07/20/git-workflows-best-practices-gitops-deployments) (the correct way of doing [DevOps](https://www.techworld-with-nana.com/devops-roadmap)) with Terraform is the approach being used here. Terraform is an [Infrastructure as Code (IaC)](https://thenewstack.io/struggling-with-it-staff-leaving-try-infrastructure-as-code/) solution.

A **Gitflow** branching model is currently setup on this configuration repository. It involves creating two main branches - “main” and “develop” - and using feature branches to develop new features. Once a feature is complete, it is merged into the “develop” branch. When the “develop” branch is stable, it is merged into the “main” branch:

- **main** branch with a **dedicated** terraform **state** file.
- **develop** branch and **other develop** branches with a **shared** terrraform **state** file:
    - All the existing branches **except main branch** are develop branches.
    - **develop** branch is the main development branch.
    - We can work on separated branches for development purposes (*development* branch, *develop_feature* branch, *feature/item* branch, *bugfix/item* branch, etc), with **all of them sharing the same terraform state file**. Check *"GIT_BRANCH"* var in:
        - [configuration/variable-group.yaml](configuration/variable-group.yaml)
        - [templates/terraform-validate.yaml](templates/terraform-validate.yaml)
        - [templates/terraform-plan.yaml](templates/terraform-plan.yaml)
        - [templates/terraform-apply.yaml](templates/terraform-apply.yaml)
        - [templates/terraform-destroy.yaml](templates/terraform-destroy.yaml)
    - Therefore, we can have several development branches with different solutions / architecture designs in case we are not sure which one is the *winning horse*.
    - **Make sure you only have one azure devops develop pipeline** pointing out to one of these git branches, otherwise more than one pipeline could have access to the same terraform state file. Each running pipeline acquires the lock of the terraform state file [to prevent others from corrupting your state](https://www.terraform.io/language/state/locking).
    - Having a dedicated state file per git branch is another option, but **we want to reuse the already deployed resources with different settings per branch** (faster than creating all the resources from scratch).



## Azure DevOps YAML Pipelines and Configuration Files

Azure DevOps YAML Pipelines:

- [01-terraform-provision-app-core-users-pipeline.yaml](01-terraform-provision-app-core-users-pipeline.yaml): Pipeline with Terraform Create
- [02-terraform-destroy-app-core-users-pipeline.yaml](02-terraform-destroy-app-core-users-pipeline.yaml): Pipeline with Terraform Destroy

Configuration files of this repo's pipelines:

- [configuration/developbranch-service-connections.yaml](configuration/developbranch-service-connections.yaml): Azure DevOps Service Connection used on this repo develop branch (GitOps pattern with a trunk branch model)
- [configuration/mainbranch-service-connections.yaml](configuration/mainbranch-service-connections.yaml): Azure DevOps Service Connection used on this repo main branch (GitOps pattern with a trunk branch model)
- [configuration/shared-azure-devops-pipeline-vars.yaml](configuration/shared-azure-devops-pipeline-vars.yaml): Shared variables among both develop and main branches.
- [configuration/variable-group.yaml](configuration/variable-group.yaml): Azure DevOps Variable Groups.

## Azure Resource Groups with Terraform State Files

- This Azure Resource Group [rg-azuredevops-pro](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azuredevops-pro/overview) contains:
    - Azure DevOps Variable Group, setup in:
        - [configuration/variable-group.yaml](configuration/variable-group.yaml)
    - **Terraform State files**, setup in [configuration/shared-azure-devops-pipeline-vars.yaml](configuration/shared-azure-devops-pipeline-vars.yaml)

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
- **DEM** (DEMO) environment is for Enterprise´s Business/Sales Demos. **It is considered as a critical/production environment.**
- **RES** (RESEARCH) environment is for Enterprise's AppAnalysis team (R&D)

Sometimes, there are more intermediate test environments, called IT, SIT (for integration testing ), or Regression (pre-release regression testing). From testing perspective, these environments ordered in such way, so application migrates to the next environment only after it is passed all tests at previous stage.

**Example:** DEV (dev tests passed) -> deploy to QA (QA integration tests passed) - > deploy to UAT (UAT acceptance tests passed) -> deploy to PRE aka STAGING (Staging tests passed) -> deploy to PRO

In terms of Continuous Deployment / Continuous Delivery, the staging environment is used to test software in a "production-like" environment, as its likely that developers will be working in an environment with significant differences to production (e.g. no load balancing, a smaller dataset etc..).

## YAML files with lists of Users to be provisioned in Enterprise Azure AD

| Type of Azure AD User Account                                  | YAML files with lists of users on Develop Branch<br>(available on this repo)                                                               | YAML files with lists of users on Main Branch<br>(available on App-Core-Users-YAML repo)                                                                                                                       |
|----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Internal Users                                                 | [20-internal-users-developbranch.yaml](terraform-manifests/20-internal-users-developbranch.yaml)                                           | [<mark>30-internal-users-mainbranch.yaml</mark>](https://dev.azure.com/EnterpriseDev/_git/App-Core-Users-YAML?path=/30-internal-users-mainbranch.yaml&version=GBdevelop)                                           |
| External Users                                                 | [40-external-users-developbranch.yaml](terraform-manifests/40-external-users-developbranch.yaml)                                           | [<mark>50-external-users-mainbranch.yaml</mark>](https://dev.azure.com/EnterpriseDev/_git/App-Core-Users-YAML?path=/50-external-users-mainbranch.yaml&version=GBdevelop)                                           |
| Manually Provisioned Internal Users<br>(i.e. Enterprise employees) | [60-internal-users-manually-provisioned-developbranch.yaml](terraform-manifests/60-internal-users-manually-provisioned-developbranch.yaml) | [<mark>70-internal-users-manually-provisioned-mainbranch.yaml</mark>](https://dev.azure.com/EnterpriseDev/_git/App-Core-Users-YAML?path=/70-internal-users-manually-provisioned-mainbranch.yaml&version=GBdevelop) |

### Matrix table with Environment Names in YAML files

| Environment Name in YAML files<br>Assigned to Enterprise's roles | Git Branch | Azure Region     | Env     | Ownership                | Permanently Deployed | DNS Zone | Env Type                   | Login URL                                           |
|:-------------------------------------------------------------|------------|------------------|---------|--------------------------|:--------------------:|----------|----------------------------|-----------------------------------------------------|
| client-anon                                                       | develop    | North Europe     | dev     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcclient-anon.deng.enterprise.com/login             |
| client-anon                                                        | develop    | North Europe     | qa      | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcclient-anon.deng.enterprise.com/login              |
| dneuat                                                       | develop    | North Europe     | uat     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdneuat.deng.enterprise.com/login             |
| dnepre                                                       | develop    | North Europe     | pre     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdnepre.deng.enterprise.com/login             |
| dnepro                                                       | develop    | North Europe     | pro     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdne.dapps.enterprise.com/login               |
| dnedem                                                       | develop    | North Europe     | dem     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdnedem.dapps.enterprise.com/login            |
| dneres                                                       | develop    | North Europe     | res     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdneres.dapps.enterprise.com/login            |
| dcusdev                                                      | develop    | Central US       | dev     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcusdev.deng.enterprise.com/login            |
| dcusqa                                                       | develop    | Central US       | qa      | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcusqa.deng.enterprise.com/login             |
| dcusuat                                                      | develop    | Central US       | uat     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcusuat.deng.enterprise.com/login            |
| dcuspre                                                      | develop    | Central US       | pre     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcuspre.deng.enterprise.com/login            |
| dcuspro                                                      | develop    | Central US       | pro     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdcus.dapps.enterprise.com/login              |
| dcusdem                                                      | develop    | Central US       | dem     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdcusdem.dapps.enterprise.com/login           |
| dcusres                                                      | develop    | Central US       | res     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdcusres.dapps.enterprise.com/login           |
| <mark>nedev</mark>                                           | **main**   | **North Europe** | **dev** | **Development Team**     |        **X**         | **eng**  | **ENGINEERING**            | <mark>https://appcnedev.eng.enterprise.com/login</mark>  |
| neqa                                                         | main       | North Europe     | qa      | Development Team         |          -           | eng      | ENGINEERING                | https://appcneqa.eng.enterprise.com/login                |
| <mark>neuat</mark>                                           | **main**   | **North Europe** | **uat** | **QA Team**              |        **X**         | **eng**  | **ENGINEERING**            | <mark>https://appcneuat.eng.enterprise.com/login</mark>  |
| nepre                                                        | main       | North Europe     | pre     | Development Team         |          -           | eng      | ENGINEERING                | https://appcnepre.eng.enterprise.com/login               |
| <mark>nepro</mark>                                           | **main**   | **North Europe** | **pro** | **DevOps & Cloud Teams** |        **X**         | **apps** | **PRODUCTION**             | <mark>https://appcne.apps.enterprise.com/login</mark>    |
| <mark>nedem</mark>                                           | **main**   | **North Europe** | **dem** | **DevOps & Cloud Teams** |        **X**         | **apps** | **PRODUCTION**             | <mark>https://appcnedem.apps.enterprise.com/login</mark> |
| <mark>neres</mark>                                           | **main**   | **North Europe** | **res** | **DevOps & Cloud Teams** |        **X**         | **apps** | **PRODUCTION**             | <mark>https://appcneres.apps.enterprise.com/login</mark> |
| cusdev                                                       | main       | Central US       | dev     | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccusdev.eng.enterprise.com/login              |
| cusqa                                                        | main       | Central US       | qa      | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccusqa.eng.enterprise.com/login               |
| cusuat                                                       | main       | Central US       | uat     | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccusuat.eng.enterprise.com/login              |
| cuspre                                                       | main       | Central US       | pre     | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccuspre.eng.enterprise.com/login              |
| cuspro                                                       | main       | Central US       | pro     | DevOps & Cloud Teams     |          -           | apps     | PRODUCTION                 | https://appccus.apps.enterprise.com/login                |
| cusdem                                                       | main       | Central US       | dem     | DevOps & Cloud Teams     |          -           | apps     | PRODUCTION                 | https://appccusdem.apps.enterprise.com/login             |
| cusres                                                       | main       | Central US       | res     | DevOps & Cloud Teams     |          -           | apps     | PRODUCTION                 | https://appccusres.apps.enterprise.com/login             |

### Key Value pairs Reference in YAML files with Internal Users

- first-name: (Optional) The given name (first name) of the internal user.
- last-name: (Optional) The user's surname (family name or last name).
- department: (Optional) The name for the department in which the user works.
- job-title: (Optional) The user’s job title.
- city: (Optional) The city in which the user is located.
- <mark>email</mark>: (Required) E-mail address of the user
- <mark>center</mark>: (Required) Center Name the user belongs to (AETitle Attribute name in Azure Custom Security attributes). Only one instance per user
- app-core-admin-role: (Optional) List of environments the user is granted **App-Core Admin Role** permissions.
- app-core-user-role: (Optional) List of environments the user is granted **App-Core User Role** permissions.
- App-Catalog-admin-role: (Optional) List of environments the user is granted **App-Catalog Admin Role** permissions (not yet implemented in App-Catalog).
- App-Catalog-user-role: (Optional) List of environments the user is granted **App-Catalog User Role** permissions (not yet implemented in App-Catalog).

### Key Value pairs Reference in YAML files with External Users

- <mark>email</mark>: (Required) E-mail address of the external user
- <mark>center</mark>: (Required) Center Name the user belongs to (AETitle Attribute name in Azure Custom Security attributes). Only one instance per user
- <mark>env</mark>: (Required) The environment the user is granted access to. Only one instance per user.
- <mark>roles</mark>: (Required) App-Core Role the user is assigned to. Two options:
    - **admin**: App-Core Admin User
    - **user**: App-Core Standard User

### Key Value pairs Reference in YAML files with Manually Provisioned Internal Users

- <mark>email</mark>: (Required) E-mail address of the user
- <mark>center</mark>: (Required) Center Name the user belongs to (AETitle Attribute name in Azure Custom Security attributes). Only one instance per user
- app-core-admin-role: (Optional) List of environments the user is granted **App-Core Admin Role** permissions.
- app-core-user-role: (Optional) List of environments the user is granted **App-Core User Role** permissions.
- App-Catalog-admin-role: (Optional) List of environments the user is granted **App-Catalog Admin Role** permissions (not yet implemented in App-Catalog).
- App-Catalog-user-role: (Optional) List of environments the user is granted **App-Catalog User Role** permissions (not yet implemented in App-Catalog).

### Example of a YAML file with an empty list of users

```yaml
---
[]
```

### Example of a YAML file with a list of Internal Users

```yaml
---
- first-name: testinternaluser001
  last-name: Scott
  department: Education
  job-title: English Teacher
  city: Madrid
  email: cloud-admin@example.com
  center: &center001 enterprise # defines anchor label &center001
  app-core-admin-role: &role001 # defines anchor label &role001
    - nedev
    - neqa
    - cusdev
    - cusqa
  app-core-user-role: &role002 # defines anchor label &role002
    - neuat
    - nepre
    - nepro
    - nedem
    - neres
    - cusuat
    - cuspre
    - cuspro
    - cusdem
    - cusres
  App-Catalog-admin-role: &role003 # defines anchor label &role003
    - nedev
  App-Catalog-user-role: &role004 # defines anchor label &role004
    - neuat
- first-name: testinternaluser002
  last-name: Halpert
  department: Sales
  job-title: Sales Manager
  city: Valencia
  email: cloud-admin@example.com
  center: client-anon
  app-core-admin-role:
    - neuat
  app-core-user-role:
    - nedev
  App-Catalog-user-role:
    - neuat
- first-name: testinternaluser003
  last-name: Beesly
  department: &department001 Engineering # defines anchor label &department001
  job-title: &job001 Engineer # defines anchor label &job001
  city: Bilbao
  email: cloud-admin@example.com
  center: client2
  app-core-admin-role:
    - neuat
  app-core-user-role:
    - nedev
  App-Catalog-user-role:
    - neuat
- first-name: testinternaluser004
  last-name: Desly
  department: *department001 # refers to the 1st department (with anchor &department001)
  job-title: *job001 # refers to the 1st job (with anchor &job001)
  city: Barcelona
  email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role: *role001 # refers to the 1st role (with anchor &role001)
  app-core-user-role: *role002  # refers to the 2nd role (with anchor &role002)
  App-Catalog-admin-role: *role003 # refers to the 3rd role (with anchor &role003)
  App-Catalog-user-role: *role004 # refers to the 4th role (with anchor &role004)
- first-name: testinternaluser005
  email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role: *role001 # refers to the 1st role (with anchor &role001)
-
  email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role: *role001 # refers to the 1st role (with anchor &role001)
- email: cloud-admin@example.com
  center: enterprise
  app-core-admin-role:
    - nedev
```

### Example of a YAML file with a list of External Users. AzureAD B2B external user (guest) invitations

[Azure AD External Identities](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/external-identities-overview) refers to all the ways you can securely interact with users outside of your organization. If you want to collaborate with partners, distributors, suppliers, or vendors, you can share your resources and define how your internal users can access external organizations. If you're a developer creating consumer-facing apps, you can manage your customers' identity experiences.

With External Identities, external users can "bring their own identities." Whether they have a corporate or government-issued digital identity, or an unmanaged social identity like Google or Facebook, they can use their own credentials to sign in. The external user’s identity provider manages their identity, and you manage access to your apps with Azure AD or Azure AD B2C to keep your resources protected.

```yaml
---
- email: cloud-admin@example.com
  center: &center001 enterprise  # defines anchor label &center001
  env: nedev
  roles: admin &role001 # defines anchor label &role001
- email: cloud-admin@example.com
  center: client-anon
  env: nedev
  roles: user &role002 # defines anchor label &role002
- email: cloud-admin@example.com
  center: *center001 # refers to the first center (with anchor &center001)
  env: neuat
  roles: *role001 # refers to the 1st role (with anchor &role001)
- email: cloud-admin@example.com
  center: *center001 # refers to the first center (with anchor &center001)
  env: nedev
  roles: *role002 # refers to the 2nd role (with anchor &role002)
- email: cloud-admin@example.com
  center: enterprise
  env: neuat
  roles: user
```

### Example of a YAML file with a list of Manually Provisioned Internal Users

```yaml
---
-
  email: cloud-admin@example.com
  center: &center001 enterprise # defines anchor label &center001
  app-core-admin-role: &role001 # defines anchor label &role001
    - nedev
    - neuat
-
  email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role: *role001 # refers to the 1st role (with anchor &role001)
-
  email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role: *role001 # refers to the 1st role (with anchor &role001)
-
  email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role: *role001 # refers to the 1st role (with anchor &role001)
- email: cloud-admin@example.com
  center: *center001 # refers to the 1st center (with anchor &center001)
  app-core-admin-role:
    - neuat
```

## Requirements and Permissions

### Matrix table with required Service Principals and Azure DevOps Service Connections

| Env                        | Service Principal in AAD                           | Service Connection in Azure DevOps | Deployment Target Azure Subscription                                                                                                      | Git branch                           | Details                                                                                                                                                                                                                            |
|:---------------------------|:---------------------------------------------------|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DEV,QA,UAT,PRE             | sp-app-core-users-enterprise-dev                         | svccon-app-core-users-dev            | [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) | main                                 | A Non-Production Deployment Target Subscription (main branch)                                                                                                                                                                      |
| PRO,DEM,RES                | sp-app-core-users-enterprise-pro                         | svccon-app-core-users-pro            | [Enterprise Core Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview)    | main                                 | A Production Deployment Target Subscription (main branch)                                                                                                                                                                          |
| DEV,QA,UAT,PRE,PRO,DEM,RES | sp-app-core-users-enterprise-devops                      | svccon-app-core-users-devops         | [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users)     | develop & other development branches | This is the Azure Subscription **where Terraform TFSTATE files are located** and a Non-Production + Production Deployment Target Subscription (develop branch)                                                                     |

### Matrix table with required Service Users and Azure DevOps Service Connections

| Service User in AAD                            | Service Connection in Azure DevOps | Details                                                                                                                                                                                                                             |
|:-----------------------------------------------|:-----------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| cloud-admin@example.com | svccon-app-core-users-yaml           | Access to Azure Repos in App-Core-User-YAML project, with Azure DevOps Personal Access Token (PAT) created by a dedicated Service User (cloud-admin@example.com). This PAT only grants **"code read"** access |

### List of permissions

1. Azure Subscriptions (indicative):
    1. Azure Subscription with Terraform TFSTATE and Azure Key Vault with Secrets: **Enterprise DevOps Subscription**
    2. Azure Subscription on main branch with **DEV** deployment target: **Enterprise DevTest Subscription**
    3. Azure Subscription on main branch with **QA** deployment target: **Enterprise DevTest Subscription**
    4. Azure Subscription on main branch with **UAT** deployment target: **Enterprise DevTest Subscription**
    5. Azure Subscription on main branch with **PRE** deployment target: **Enterprise DevTest Subscription**
    6. Azure Subscription on main branch with **PRO** deployment target: **Enterprise Core Subscription** (a PROduction subscription)
    7. Azure Subscription on main branch with **DEM** (DEMO) deployment target: **Enterprise DevTest Subscription**
    8. Azure Subscription on main branch with **RES** (RESEARCH) deployment target: **Enterprise DevTest Subscription**
2. [Azure DevOps Terraform Extension: Terraform by Microsoft DevLabs](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
3. Azure DevOps Environments: Make sure the following environments are defined in [Azure DevOps environments](https://dev.azure.com/EnterpriseDev/App-Core/_environments):
    - dev
    - pro
4. **sp-app-core-users-enterprise-devops** Service Principal leveraged by this pipeline with these settings:
    1. API Permissions:
        - User.Read - Delegated
        - [User.Invite.All](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/invitation) application roles (Microsoft Graph - Application permissions). Click on **"Grant admin consent for enterprise.com"**
        - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
    2. AAD Management Scope - Azure AD Roles - Attribute assignment administrator | Assignments :
        - **sp-app-core-users-enterprise-devops**
    3. AAD Management Scope - Azure AD Roles - User Administrator | Assignments :
        - **sp-app-core-users-enterprise-devops**
            - Type: Service Principal
            - Scope: Directory
            - Membership: Directory
            - State: Assigned
            - End time: Permanent
5. **sp-app-core-users-enterprise-dev** Service Principal leveraged by this pipeline with these settings:
    1. API Permissions:
        - User.Read - Delegated
        - [User.Invite.All](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/invitation) application roles (Microsoft Graph - Application permissions). Click on **"Grant admin consent for enterprise.com"**
        - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
    2. AAD Management Scope - Azure AD Roles - Attribute assignment administrator | Assignments :
        - **sp-app-core-users-enterprise-dev**
    3. AAD Management Scope - Azure AD Roles - User Administrator | Assignments :
        - **sp-app-core-users-enterprise-dev**
            - Type: Service Principal
            - Scope: Directory
            - Membership: Directory
            - State: Assigned
            - End time: Permanent
6. **sp-app-core-users-enterprise-pro** Service Principal leveraged by this pipeline with these settings:
    1. API Permissions:
        - User.Read - Delegated
        - [User.Invite.All](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/invitation) application roles (Microsoft Graph - Application permissions). Click on **"Grant admin consent for enterprise.com"**
        - Creation of secret/credential to be used by Azure DevOps Service Connection (authentication)
    2. AAD Management Scope - Azure AD Roles - Attribute assignment administrator | Assignments :
        - **sp-app-core-users-enterprise-pro**
    3. AAD Management Scope - Azure AD Roles - User Administrator | Assignments :
        - **sp-app-core-users-enterprise-pro**
            - Type: Service Principal
            - Scope: Directory
            - Membership: Directory
            - State: Assigned
            - End time: Permanent
7. **Built-in RBAC Permissions** [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users) (Subscription Scope):
    - This is the Azure Subscription **where Terraform TFSTATE files are located**.
    - Access Control (IAM) -> Role Assignments -> **"Contributor"** assigned to:
        - **sp-app-core-users-enterprise-dev**
        - **sp-app-core-users-enterprise-pro**
8. **Built-in RBAC Permissions** on [Enterprise DevOps Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/users) as **deployment target subscription** (Subscription Scope):
    - This is the Azure Subscription **where Terraform TFSTATE files are located**.
    - This is the Deployment Target Subscription used by our IaC development branch.
    - Access Control (IAM) -> Role Assignments -> **"Owner"** assigned to:
        - **sp-app-core-users-enterprise-devops**
        - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
            - Dedicated administrators group for this Azure Subscription
            - Condition: None
9. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise DevTest Subscription](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope) assigned to **DEV environment**:
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (Contributor role is not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - Assigned to:
                - **sp-app-core-users-enterprise-dev**  (it needs to assign roles in Azure RBAC)
                - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                    - Dedicated administrators group for this Azure Subscription
                    - Condition: None
10. **Built-in RBAC Permissions on each deployment target subscription**, i.e. [Enterprise Core Subscription (a PRO subscription)](https://portal.azure.com/#@enterprise.com/resource/subscriptions/00000000-0000-0000-0000-000000000000/overview) (Subscription Scope) assigned to **PRO environment**:
    - Access Control (IAM) -> Role Assignments:
        - **"Owner"**: Required and tested (Contributor role is not enough)
            - Grants full access to manage all resources, including the ability to assign roles in Azure RBAC.
            - Assigned to:
                - **sp-app-core-users-enterprise-pro**  (it needs to assign roles in Azure RBAC)
                - AAD Group: [**"Subscription_Admins_Enterprise_DevOps"**](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/00000000-0000-0000-0000-000000000000)
                    - Dedicated administrators group for this Azure Subscription
                    - Condition: None
11. Azure DevOps [svccon-app-core-users-devops Service Connection](https://dev.azure.com/EnterpriseDev/App-Core-Users/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: 00000000-0000-0000-0000-000000000000  (Enterprise DevOps Subscription)
    - Subscription Name: **Enterprise DevOps Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-app-core-users-enterprise-devops)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-app-core-users-devops**
    - Description: Connects to Enterprise DevOps Subscription via sp-app-core-users-enterprise-devops, **where Terraform TFSTATE files are located**
    - Grant access permissions to all pipelines: **enabled**
12. Azure DevOps Service Connection: **Permissions on each deployment target subscription**, i.e. **DEV environment** assigned to **Enterprise DevTest Subscription** and reached via a [svccon-app-core-users-dev Service Connection](https://dev.azure.com/EnterpriseDev/App-Core-Users/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise DevTest Subscription)
    - Subscription Name: **Enterprise DevTest Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-app-core-users-enterprise-dev)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-app-core-users-dev**
    - Description: Connects to Enterprise DevTest Subscription via sp-app-core-users-enterprise-dev, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**
13. Azure DevOps Service Connection: **Permissions on each deployment target subscription**, i.e. **PRO environment** assigned to **Enterprise Core Subscription** and reached via a [svccon-app-core-users-pro Service Connection](https://dev.azure.com/EnterpriseDev/App-Core-Users/_settings/adminservices) created with "Azure Resource Manager" using service principal **(manual)**:
    - Environment: Azure Cloud
    - Scope Level: Subscription
    - Subscription Id: **00000000-0000-0000-0000-000000000000**  (Enterprise Core Subscription)
    - Subscription Name: **Enterprise Core Subscription**
    - Service Principal Id: **00000000-0000-0000-0000-000000000000**   (sp-app-core-users-enterprise-pro)
    - Credential -> Service principal key: The one setup in previous step
    - Tenant ID: 00000000-0000-0000-0000-000000000000  (our AAD tenant)
    - Service Connection Name: **svccon-app-core-users-pro**
    - Description: Connects to Enterprise Core Subscription via sp-app-core-users-enterprise-pro, a deployment target subscription.
    - Grant access permissions to all pipelines: **enabled**

   **Tip**: use [this tool](https://www.tablesgenerator.com/) or [this other one](https://marketplace.visualstudio.com/items?itemName=csholmq.excel-to-markdown-table) to edit the above table.

## FAQ

### Render terraform graphs with Graphviz

Grab the outcome of **terraform graph** from Azure DevOps Pipeline Logs and render a graph with tools like [GraphViz](https://graphviz.org/) to visualize our terraform settings:

```bash
brew install graphviz
dot -Tpng terraform_graph_app-core.out -o graph.png
```

Similarly, we can also use the online [Graphviz website](https://dreampuf.github.io/GraphvizOnline/) to get a visual representation of the terraform configurations.

[Reference](https://blog.knoldus.com/how-to-use-terraform-graph-to-visualize-your-execution-plan/)

### How to rollback in a GitOps flow with Azure DevOps pipelines

We can easily rollback to an older configuration if our latest change/commit breaks something:

| Step                                                            | Screenshot                                                             |
|-----------------------------------------------------------------|------------------------------------------------------------------------|
| 1) Get git commit sha                                           |            |
| 2) Run Azure DevOps pipeline with a git tag or a git commit sha |  |
| 3) Run pipeline on the corresponding environment                |  |

## References

### YAML

- [wikipedia.org: YAML](https://en.wikipedia.org/wiki/YAML)
- [hitchdev.com: An example of a snippet of YAML that uses node anchors and references is described on the YAML wikipedia page](https://hitchdev.com/strictyaml/why/node-anchors-and-references-removed/)
- [gettaurus.org: YAML Tutorial](https://www.gettaurus.org/docs/YAMLTutorial/)
- [linuxhandbook.com: YAML Basics Every DevOps Engineer Must Know](https://linuxhandbook.com/yaml-basics/)
- [redhat.com: 10 YAML tips for people who hate YAML](https://www.redhat.com/sysadmin/yaml-tips)

### Azure AD

- [returngis.net: Invite external users to an Azure AD tenant via Microsoft Graph and Azure CLI](https://www.returngis.net/2023/04/invitar-a-usuarios-externos-a-un-tenant-de-azure-ad-a-traves-de-microsoft-graph-y-azure-cli/)
- [learn.microsoft.com: B2B collaboration overview](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)
- [learn.microsoft.com: Quickstart: Add a guest user and send an invitation](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/b2b-quickstart-add-guest-users-portal)
- [learn.microsoft.com: Quickstart: Properties of an Azure Active Directory B2B collaboration user](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/user-properties)
- [learn.microsoft.com: Add guest users to an application](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/add-users-administrator#add-guest-users-to-an-application)
- [learn.microsoft.com: Security tokens](https://learn.microsoft.com/en-us/azure/active-directory/develop/security-tokens)

### Terraform

- [dev.to: How to Manage Active Directory Objects with Azure AD Provider for Terraform](https://dev.to/spacelift/how-to-manage-active-directory-objects-with-azure-ad-provider-for-terraform-9e2)
- [developer.hashicorp.com: flatten Function](https://developer.hashicorp.com/terraform/language/functions/flatten)
- [plainenglish.io: Terraform + Yaml = ❤️](https://plainenglish.io/blog/terraform-yaml)
- [developer.hashicorp.com: Manage Azure Active Directory (Azure AD) Users and Groups](https://developer.hashicorp.com/terraform/tutorials/it-saas/azure-ad)
- [github.com/hashicorp: Learn Terraform Azure AD](https://github.com/hashicorp/learn-terraform-azure-ad)

### Git

- [dev.to: A Simplified Convention for Naming Branches and Commits in Git](https://dev.to/varbsan/a-simplified-convention-for-naming-branches-and-commits-in-git-il4)
