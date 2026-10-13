# Azure Terraform Infrastructure

A hands-on Azure infrastructure project built with Terraform, Microsoft Entra ID, Azure RBAC, and GitHub Actions.

The goal is to demonstrate practical infrastructure-as-code skills, secure identity configuration, remote Terraform state management, and automated validation of infrastructure changes.

This is a personal learning and portfolio project, not a representation of commercial production experience with Terraform.

## Project status

Implemented:
- GitHub repository and Terraform project structure
- Separate Terraform bootstrap configuration for remote state storage
- Azure Blob Storage remote backend
- Microsoft Entra ID authentication for Terraform
- GitHub Actions authentication to Azure using OpenID Connect (OIDC)
- Automated Terraform formatting checks, validation, and planning
- Foundational Azure networking: VNet, subnets, and NSG

Planned next:
- Azure Key Vault with RBAC authorization
- User-assigned managed identity
- Least-privilege access to Key Vault secrets
- Azure Service Bus and additional security/networking improvements, subject to cost and scope review

## Architecture

### Terraform state infrastructure

The bootstrap configuration creates and manages the resources required for the main Terraform remote backend.

- Resource group: `rg-tfstate`
- Storage account: `tfstateivanov2026`
- Blob container: `tfstate`
- Main state blob: `azure-terraform-infrastructure.tfstate`

The bootstrap configuration is kept separate from the main configuration because the remote state storage must exist before the main backend can use it.

The bootstrap Terraform state is stored locally in the `bootstrap` directory. It is excluded from Git and must not be committed.

### Main Azure infrastructure

- Resource group: `rg-terraform-demo`
- Region: `West Europe`
- Virtual network: `vnet-terraform-demo`
- VNet address space: `10.20.0.0/16`

Subnets:

| Subnet | Address range | Purpose |
|---|---|---|
| `snet-workload` | `10.20.1.0/24` | Workload resources |
| `snet-private-endpoints` | `10.20.2.0/24` | Reserved for future Private Endpoints |

Network security:

- Network Security Group: `nsg-workload`
- The NSG is associated with `snet-workload`.
- An explicit rule denies inbound traffic from the public Internet.
- Azure's default inbound deny rule also remains in effect.
- No NSG is currently associated with `snet-private-endpoints`.

The project currently deploys no virtual machines, public IP addresses, NAT Gateway, or Private Endpoints.

## Terraform design

The root Terraform configuration manages the main infrastructure and uses an Azure Blob Storage backend.

The bootstrap configuration is independent and uses local state to create the remote backend resources.

The AzureRM provider is configured through Terraform files, and the dependency lock files are committed to support consistent provider selection.

The remote state container is private. Terraform accesses state using Microsoft Entra ID and Azure RBAC rather than storing a Storage Account access key in the repository.

## GitHub Actions and OIDC

The `Terraform CI` workflow runs when changes are pushed to `main` and can also be triggered manually.

The workflow performs:

1. Repository checkout
2. Azure authentication through OIDC
3. Terraform setup
4. Terraform formatting check
5. Terraform initialization
6. Terraform validation
7. Terraform plan

GitHub Actions authenticates through a Microsoft Entra application and federated identity credentials associated with this repository and branch.

Repository secrets contain the Azure Client ID, Tenant ID, and Subscription ID required for authentication. No long-lived client secret or Storage Account key is stored in GitHub.

The GitHub Actions identity has:
- `Reader` access to the Azure subscription for infrastructure planning
- `Storage Blob Data Contributor` access to the Terraform state container

The workflow does not run `terraform apply`. Infrastructure changes are applied locally after reviewing the Terraform plan.

## Security considerations

- Azure RBAC is used for authorization to the Terraform state container.
- Anonymous public blob access is disabled.
- The Storage Account is configured in Terraform to require TLS 1.2 or later.
- Public network access to the state Storage Account remains enabled for this lab.
- The workload NSG explicitly denies inbound traffic from the Internet.
- GitHub-to-Azure authentication uses OIDC rather than a long-lived client secret.
- The main GitHub workflow uses a read-only subscription role and cannot apply infrastructure changes.
- Key Vault, managed identity, and their RBAC assignments are part of the next planned implementation stage.

Public network access to the state Storage Account is a lab simplification. A production implementation should evaluate private connectivity, network restrictions, and the appropriate recovery and access-control design.

## Repository structure

```text
azure-terraform-infrastructure/
├── .github/
│   └── workflows/
│       └── terraform-plan.yml
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
├── backend.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── variables.tf
├── versions.tf
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

The bootstrap directory also has a local Terraform state file when initialized and applied. The state file and generated Terraform directories are intentionally excluded from version control.

## Running Terraform locally

Requirements:
- Terraform CLI
- Azure CLI
- Access to the relevant Azure subscription
- Appropriate Azure permissions to create the required resources and role assignments

Authenticate to Azure:

```powershell
az login --use-device-code
az account set --subscription "Visual Studio Enterprise Subscription"
az account show --output table
```

From the repository root, run:

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

Review the full plan before applying any changes. Apply only when the proposed resource changes are understood and expected:

```powershell
terraform apply
```

Do not commit Terraform state files, credentials, client secrets, private keys, or sensitive variable files.

## Cost and scope

The initial network foundation uses resources that do not require virtual machines or dedicated network appliances. Future Azure services and networking components will be assessed before deployment.

Azure resource usage can incur charges. Review the planned resources and applicable Azure pricing before applying changes.

## Recovery and portability

The GitHub repository preserves the Terraform source code and workflow definitions independently of the current Azure subscription.

If the original subscription becomes unavailable, deployment into another subscription requires a working Azure subscription, a new or available state Storage Account, appropriate permissions, and an updated backend configuration. Existing Azure resources and state do not automatically transfer to a new subscription.

Do not reuse an old local or remote state blindly in a different subscription. Review the target environment and initialize the backend deliberately.

## Learning objectives

This project demonstrates hands-on work with:

- Terraform configuration, validation, planning, and state
- Azure Blob Storage remote state
- Microsoft Entra ID and workload identity federation
- Azure RBAC and least-privilege access
- Azure Virtual Networks, subnets, and NSGs
- GitHub Actions CI
- Infrastructure change review and security documentation
