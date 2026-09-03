# Table of Contents

1. [Enterprise App-Core-Users-YAML Repo with the database of User Accounts to provision by App-Core-Users Pipeline](#enterprise-app-core-users-yaml-repo-with-the-database-of-user-accounts-to-provision-by-app-core-users-pipeline)
2. [Environments](#environments)
3. [YAML files with lists of Users to be provisioned in Enterprise Azure AD](#yaml-files-with-lists-of-users-to-be-provisioned-in-enterprise-azure-ad)
  1. [Matrix table with Environment Names in YAML files](#matrix-table-with-environment-names-in-yaml-files)
  2. [Key Value pairs Reference in YAML files with Internal Users](#key-value-pairs-reference-in-yaml-files-with-internal-users)
  3. [Key Value pairs Reference in YAML files with External Users](#key-value-pairs-reference-in-yaml-files-with-external-users)
  4. [Key Value pairs Reference in YAML files with Manually Provisioned Internal Users](#key-value-pairs-reference-in-yaml-files-with-manually-provisioned-internal-users)
  5. [Example of a YAML file with an empty list of users](#example-of-a-yaml-file-with-an-empty-list-of-users)
  6. [Example of a YAML file with a list of Internal Users](#example-of-a-yaml-file-with-a-list-of-internal-users)
  7. [Example of a YAML file with a list of External Users. AzureAD B2B external user (guest) invitations](#example-of-a-yaml-file-with-a-list-of-external-users-azuread-b2b-external-user-guest-invitations)
  8. [Example of a YAML file with a list of Manually Provisioned Internal Users](#example-of-a-yaml-file-with-a-list-of-manually-provisioned-internal-users)
4. [References](#references)
  1. [YAML](#enterprise-app-core-users-yaml-repo-with-the-database-of-user-accounts-to-provision-by-app-core-users-pipeline)
  2. [Azure AD](#yaml-files-with-lists-of-users-to-be-provisioned-in-enterprise-azure-ad)

## Enterprise App-Core-Users-YAML Repo with the database of User Accounts to provision by App-Core-Users Pipeline

This repo contains the YAML files with the lists of users to be provisioned and setup by [App-Core-Users Pipeline](https://dev.azure.com/EnterpriseDev/App-Core-Users).

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

| Type of Azure AD User Account                                  | YAML files with lists of users                                                                                                |
|----------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Internal Users                                                 | [<mark>30-internal-users-mainbranch.yaml</mark>](30-internal-users-mainbranch.yaml)                                           |
| External Users                                                 | [<mark>50-external-users-mainbranch.yaml</mark>](50-external-users-mainbranch.yaml)                                           |
| Manually Provisioned Internal Users<br>(i.e. Enterprise employees) | [<mark>70-internal-users-manually-provisioned-mainbranch.yaml</mark>](70-internal-users-manually-provisioned-mainbranch.yaml) |

### Matrix table with Environment Names in YAML files

| Environment Name in YAML files<br>Assigned to Enterprise's roles | Git Branch | Azure Region     | Env     | Ownership                | Permanently Deployed | DNS Zone | Env Type                   | Login URL                                           |
|:-------------------------------------------------------------|------------|------------------|---------|--------------------------|:--------------------:|----------|----------------------------|-----------------------------------------------------|
| client-anon                                                       | develop    | North Europe     | dev     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcclient-anon.deng.enterprise.com/login             |
| client-anon                                                        | develop    | North Europe     | qa      | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcclient-anon.deng.enterprise.com/login              |
| dneuat                                                       | develop    | North Europe     | uat     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdneuat.deng.enterprise.com/login             |
| dnepre                                                       | develop    | North Europe     | pre     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdnepre.deng.enterprise.com/login             |
| dnepro                                                       | develop    | North Europe     | pro     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdnepro.dapps.enterprise.com/login            |
| dnedem                                                       | develop    | North Europe     | dem     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdnedem.dapps.enterprise.com/login            |
| dneres                                                       | develop    | North Europe     | res     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdneres.dapps.enterprise.com/login            |
| dcusdev                                                      | develop    | Central US       | dev     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcusdev.deng.enterprise.com/login            |
| dcusqa                                                       | develop    | Central US       | qa      | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcusqa.deng.enterprise.com/login             |
| dcusuat                                                      | develop    | Central US       | uat     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcusuat.deng.enterprise.com/login            |
| dcuspre                                                      | develop    | Central US       | pre     | DevOps Team              |          -           | deng     | Engineering Develop Branch | https://appcdcuspre.deng.enterprise.com/login            |
| dcuspro                                                      | develop    | Central US       | pro     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdcuspro.dapps.enterprise.com/login           |
| dcusdem                                                      | develop    | Central US       | dem     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdcusdem.dapps.enterprise.com/login           |
| dcusres                                                      | develop    | Central US       | res     | DevOps Team              |          -           | dapps    | Production Develop Branch  | https://appcdcusres.dapps.enterprise.com/login           |
| <mark>nedev</mark>                                           | **main**   | **North Europe** | **dev** | **Development Team**     |        **X**         | **eng**  | **ENGINEERING**            | <mark>https://appcnedev.eng.enterprise.com/login</mark>  |
| neqa                                                         | main       | North Europe     | qa      | Development Team         |          -           | eng      | ENGINEERING                | https://appcneqa.eng.enterprise.com/login                |
| <mark>neuat</mark>                                           | **main**   | **North Europe** | **uat** | **QA Team**              |        **X**         | **eng**  | **ENGINEERING**            | <mark>https://appcneuat.eng.enterprise.com/login</mark>  |
| nepre                                                        | main       | North Europe     | pre     | Development Team         |          -           | eng      | ENGINEERING                | https://appcnepre.eng.enterprise.com/login               |
| <mark>nepro</mark>                                           | **main**   | **North Europe** | **pro** | **DevOps & Cloud Teams** |        **X**         | **apps** | **PRODUCTION**             | <mark>https://appcnepro.apps.enterprise.com/login</mark> |
| <mark>nedem</mark>                                           | **main**   | **North Europe** | **dem** | **DevOps & Cloud Teams** |        **X**         | **apps** | **PRODUCTION**             | <mark>https://appcnedem.apps.enterprise.com/login</mark> |
| <mark>neres</mark>                                           | **main**   | **North Europe** | **res** | **DevOps & Cloud Teams** |        **X**         | **apps** | **PRODUCTION**             | <mark>https://appcneres.apps.enterprise.com/login</mark> |
| cusdev                                                       | main       | Central US       | dev     | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccusdev.eng.enterprise.com/login              |
| cusqa                                                        | main       | Central US       | qa      | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccusqa.eng.enterprise.com/login               |
| cusuat                                                       | main       | Central US       | uat     | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccusuat.eng.enterprise.com/login              |
| cuspre                                                       | main       | Central US       | pre     | DevOps & Cloud Teams     |          -           | eng      | ENGINEERING                | https://appccuspre.eng.enterprise.com/login              |
| cuspro                                                       | main       | Central US       | pro     | DevOps & Cloud Teams     |          -           | apps     | PRODUCTION                 | https://appccuspro.apps.enterprise.com/login             |
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
