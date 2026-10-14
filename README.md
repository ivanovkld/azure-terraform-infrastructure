# Azure Terraform Infrastructure

A hands-on Azure infrastructure portfolio project built with Terraform, Microsoft Azure, Microsoft Entra ID, Azure RBAC, and GitHub Actions.

The project demonstrates infrastructure-as-code, remote Terraform state management, workload identity, least-privilege authorization, private networking, and automated infrastructure validation.

This is a personal learning project. It demonstrates hands-on implementation and does not represent commercial production experience with Terraform.

## Project status

Implemented:

- Terraform bootstrap configuration for remote state storage
- Azure Blob Storage remote backend
- GitHub Actions authentication through Microsoft Entra ID OpenID Connect (OIDC)
- Automated Terraform formatting checks, validation, and planning
- Azure Virtual Network, subnets, and Network Security Group
- Azure Key Vault with RBAC authorization and private connectivity
- User-assigned Managed Identity and least-privilege RBAC assignments
- Azure Service Bus Standard namespace and message queue
- Queue-scoped Service Bus Sender and Receiver roles
- Private Endpoint and Private DNS validation using a temporary Linux VM
- Evidence of successful Key Vault access through private networking and Managed Identity

## Architecture

### Terraform state infrastructure

The bootstrap configuration creates the resources required by the main Terraform backend.

- Resource group: `rg-tfstate`
- Storage account: `tfstateivanov2026`
- Blob container: `tfstate`
- Main state blob: `azure-terraform-infrastructure.tfstate`

The bootstrap configuration is separate because the remote state storage must exist before the main Terraform configuration can use it.

The bootstrap Terraform state is stored locally in the `bootstrap` directory and excluded from Git. The main Terraform configuration stores its state in Azure Blob Storage.

The state container is private. Terraform accesses it using Microsoft Entra ID and Azure RBAC rather than a Storage Account access key stored in the repository.

### Network foundation

- Resource group: `rg-terraform-demo`
- Region: `West Europe`
- Virtual network: `vnet-terraform-demo`
- Address space: `10.20.0.0/16`

| Resource | Address range or setting | Purpose |
|---|---|---|
| `snet-workload` | `10.20.1.0/24` | Workload resources and validation VM |
| `snet-private-endpoints` | `10.20.2.0/24` | Private Endpoint network interfaces |
| `nsg-workload` | Inbound Internet deny rule | Network security for the workload subnet |

The workload subnet is associated with `nsg-workload`. The NSG explicitly denies inbound traffic from the public Internet; Azure's default inbound deny rule also remains in effect.

### Key Vault and private networking

- Key Vault: `kv-tf-infra-c7c86f`
- Authorization: Azure RBAC
- Soft delete: enabled, 7-day retention
- Purge protection: enabled
- Public network access: disabled
- Private Endpoint: `pe-kv-terraform-demo`
- Private DNS zone: `privatelink.vaultcore.azure.net`

The Private DNS zone is linked to the project VNet. Its A record directs clients in the VNet to the Key Vault private IP address.

A validation test from a VM in the VNet confirmed private DNS resolution, Managed Identity token acquisition, and an HTTP 200 response from the Key Vault data plane.

### Workload Managed Identity

- Managed Identity: `id-terraform-demo-workload`
- Key Vault role: `Key Vault Secrets User`
- Key Vault role scope: the individual Key Vault

The workload identity can read secrets from this Key Vault without storing a client secret. No secret values were provisioned as part of this project.

### Azure Service Bus

- Namespace: `sb-tf-infra-c7c86f`
- SKU: Standard
- Queue: `q-work-items`
- Local SAS authentication: disabled
- Minimum TLS version: 1.2

The workload Managed Identity has the following roles, scoped to the queue:

- `Azure Service Bus Data Sender`
- `Azure Service Bus Data Receiver`

These assignments allow the identity to send and receive messages at the queue scope rather than granting data-plane access across the entire subscription.

The project implements the Service Bus namespace, queue, and authorization. It does not include a separate business application that sends and receives production messages.

Service Bus public network access remains enabled as a lab simplification.

### Private connectivity validation VM

- VM: `vm-kv-pe-test`
- Size: `Standard_B1s`
- Operating system: Ubuntu 24.04 LTS
- Public IP: none
- Managed Identity: `id-terraform-demo-workload`

The VM was used to verify private DNS resolution and access to Key Vault through Managed Identity. It is retained temporarily for evidence collection while the lab subscription remains available.

The workload subnet currently has default outbound access enabled to support the lab validation and VM management workflow. This is a lab limitation rather than a recommended long-term production configuration.

The repository contains only the public SSH key used by the VM configuration. No private SSH key is committed.

## Terraform design

The root Terraform configuration manages the main Azure infrastructure and uses an Azure Blob Storage remote backend.

The bootstrap configuration is maintained separately because it creates the storage resources required by the main backend.

Terraform configuration is declarative: the `.tf` files describe the desired infrastructure, and Terraform compares this configuration with the current state to produce a plan. Applying an approved plan creates, updates, or deletes Azure resources as necessary.

The `.terraform.lock.hcl` files are committed to support consistent provider selection.

## GitHub Actions and OIDC

The `Terraform CI` workflow runs when changes are pushed to the `main` branch and can also be triggered manually.

The workflow performs:

1. Repository checkout
2. Azure authentication through OIDC
3. Terraform setup
4. Terraform formatting check
5. Terraform initialization
6. Terraform validation
7. Terraform plan

GitHub Actions runs Terraform in a separate, temporary runner environment rather than relying on the local development computer.

The Microsoft Entra federated identity is associated with this repository and branch. GitHub Secrets provide the Client ID, Tenant ID, and Subscription ID required for authentication. No long-lived client secret or Storage Account access key is stored in GitHub.

The GitHub Actions identity has:
- `Reader` access to the Azure subscription for infrastructure planning
- `Storage Blob Data Contributor` access to the Terraform state container

The workflow does not run `terraform apply`. Infrastructure changes are applied locally after reviewing the Terraform plan.

This CI workflow demonstrates automated infrastructure validation. It is not a complete corporate change-approval pipeline: mandatory pull request reviews and production deployment approvals are not configured in this lab.

## Security considerations

- Azure RBAC protects access to the Terraform state container.
- Anonymous public blob access is disabled.
- The Terraform bootstrap configuration specifies TLS 1.2 for the state Storage Account.
- Public network access to the state Storage Account remains enabled for this lab.
- Key Vault public network access is disabled and private connectivity is provided through Private Endpoint.
- Key Vault uses Azure RBAC, soft delete, and purge protection.
- The workload NSG explicitly denies inbound Internet traffic.
- The validation VM has no public IP.
- Default outbound access remains enabled for the workload subnet as a lab limitation.
- Service Bus local SAS authentication is disabled, while public network access remains enabled.
- GitHub-to-Azure authentication uses OIDC rather than a long-lived client secret.
- The GitHub Actions identity cannot apply infrastructure changes.

A production implementation should review outbound network controls, private connectivity, monitoring, recovery requirements, change approvals, and resource costs.

## Evidence and screenshots

Screenshots are stored in `docs/screenshots/`. They preserve evidence of the deployed architecture and successful checks independently of the Azure subscription.

| Screenshot | Evidence |
|---|---|
| [01 — Remote Terraform state](docs/screenshots/01%20%E2%80%94%20Remote%20Terraform%20state.png) | Storage Account and Terraform state blob |
| [02 — VNet and subnets](docs/screenshots/02%20%E2%80%94%20Vnet%20and%20subnets.png) | VNet address space and subnet ranges |
| [03 — NSG](docs/screenshots/03%20%E2%80%94%20NSG.png) | Inbound Internet deny rule |
| [04 — Key Vault Networking](docs/screenshots/04%20%E2%80%94%20Key%20Vault%20Networking.png) | Public network access disabled |
| [05 — Key Vault Private Endpoint](docs/screenshots/05%20%E2%80%94%20Key%20Vault%20Private%20Endpoint.png) | Private connection information in Key Vault |
| [06 — Private Endpoint](docs/screenshots/06%20%E2%80%94%20Private%20Endpoint.png) | Private Endpoint resource and connection status |
| [07 — Private DNS](docs/screenshots/07%20%E2%80%94%20Private%20DNS.png) | Private DNS zone and record |
| [08 — Key Vault RBAC](docs/screenshots/08%20%E2%80%94%20Key%20Vault%20RBAC.png) | `Key Vault Secrets User` assignment |
| [09 — Managed Identity](docs/screenshots/09%20%E2%80%94%20Managed%20Identity.png) | User-assigned workload identity |
| [10 — Service Bus](docs/screenshots/10%20%E2%80%94%20Service%20Bus.png) | Standard namespace and queue |
| [11 — Service Bus RBAC](docs/screenshots/11%20%E2%80%94%20Service%20Bus%20RBAC.png) | Sender and Receiver assignments |
| [12 — VM](docs/screenshots/12%20%E2%80%94%20VM.png) | Validation VM without a public IP |
| [13 — Private Connectivity Test](docs/screenshots/13%20%E2%80%94%20Private%20Connectivity%20Test.png) | DNS resolution, Managed Identity, and HTTP 200 |
| [14 — Terraform No Changes](docs/screenshots/14%20%E2%80%94%20Terraform%20No%20Changes.png) | Terraform state matches the configuration |
| [15 — GitHub Actions Success](docs/screenshots/15%20%E2%80%94%20Github%20Actions%20Success.png) | Successful Terraform CI workflow |

Screenshots document the actual checks performed. They do not contain access tokens, passwords, private keys, or Terraform state contents.

## Repository structure

```text
azure-terraform-infrastructure/
├── .github/
│   └── workflows/
│       └── terraform-plan.yml
├── assets/
│   └── azure-terraform-kv-pe-test.pub
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
├── docs/
│   └── screenshots/
├── backend.tf
├── identity.tf
├── key_vault.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── service_bus.tf
├── test_vm.tf
├── variables.tf
├── versions.tf
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

Generated `.terraform` directories, Terraform state files, private SSH keys, credentials, and sensitive variable files are intentionally excluded from version control.

## Running Terraform locally

Requirements:

- Terraform CLI
- Azure CLI
- Access to an Azure subscription
- Appropriate Azure permissions for the resources being managed

Authenticate to Azure:

```powershell
az login --use-device-code
az account set --subscription "Visual Studio Enterprise Subscription"
az account show --output table
```

From the repository root:

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

Review the plan before applying any changes. Apply only when the proposed changes are understood and expected:

```powershell
terraform apply
```

The validation VM is enabled by default in the current lab configuration so that local Terraform and GitHub Actions can describe the same deployed infrastructure. Its public key is read from `assets/azure-terraform-kv-pe-test.pub`.

## Cost and lifecycle

Azure resources can incur charges while they exist. The current environment includes a Standard_B1s VM, managed disk, Service Bus Standard namespace, Private Endpoint, and other Azure resources.

The resources are retained temporarily for evidence collection before the original lab subscription becomes unavailable. Review Azure Cost Management and applicable pricing before extending the environment or recreating it in another subscription.

## Recovery and portability

GitHub preserves the Terraform source code, workflow definitions, public test key, and evidence independently of the original subscription.

If the original subscription becomes unavailable, deployment into another subscription requires a valid target subscription, a usable state backend, appropriate permissions, and a deliberate backend configuration. Azure resources and Terraform state do not automatically transfer to a different subscription.

Do not reuse old state blindly in a new subscription. Review the target environment and establish the backend deliberately.

## Learning objectives

This project demonstrates hands-on work with:

- Terraform configuration, formatting, validation, planning, and state
- Azure Blob Storage remote state and a separate bootstrap configuration
- Microsoft Entra ID and workload identity federation
- Azure RBAC and least-privilege authorization
- Azure Virtual Networks, subnets, NSGs, and Private Endpoints
- Private DNS configuration and validation
- Key Vault, Managed Identity, and service-level access controls
- Azure Service Bus and queue-scoped RBAC
- GitHub Actions CI and infrastructure change review
- Security documentation and technical evidence
