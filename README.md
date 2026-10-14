# Azure Terraform Infrastructure

A hands-on Azure infrastructure portfolio project built with Terraform, Microsoft Azure, Microsoft Entra ID, Azure RBAC, and GitHub Actions.

The project demonstrates infrastructure-as-code, remote Terraform state, workload identity, least-privilege authorization, private networking, and automated infrastructure validation.

This is a personal hands-on learning project, not a claim of commercial production experience with Terraform.

## Project status

Implemented:

- Separate Terraform bootstrap configuration for the remote state backend
- Azure Blob Storage remote state
- GitHub Actions authentication to Azure through Microsoft Entra ID OpenID Connect (OIDC)
- Automated Terraform formatting checks, validation, and planning
- Azure Virtual Network, subnets, and Network Security Group
- Azure Key Vault with RBAC authorization and private connectivity
- User-assigned Managed Identity and least-privilege RBAC assignments
- Azure Service Bus Standard namespace and message queue
- Queue-scoped Service Bus Sender and Receiver roles
- Temporary private-connectivity validation VM with no public IP
- Evidence of Key Vault access through Private Endpoint and Managed Identity

## Architecture

### Terraform state infrastructure

The bootstrap configuration creates the resources required by the main Terraform backend.

- Resource group: `rg-tfstate`
- Storage account: `tfstateivanov2026`
- Blob container: `tfstate`
- Main state blob: `azure-terraform-infrastructure.tfstate`

The bootstrap configuration is kept separate because the remote state storage must exist before the main Terraform backend can use it.

Bootstrap state is stored locally in the `bootstrap` directory and excluded from version control. The main Terraform state is stored in Azure Blob Storage.

The state container is private and accessed using Microsoft Entra ID and Azure RBAC. No Storage Account access key is stored in the repository.

### Network foundation

- Resource group: `rg-terraform-demo`
- Region: `West Europe`
- Virtual network: `vnet-terraform-demo`
- Address space: `10.20.0.0/16`

| Resource | Address range or setting | Purpose |
|---|---|---|
| `snet-workload` | `10.20.1.0/24` | Workload resources and validation VM |
| `snet-private-endpoints` | `10.20.2.0/24` | Private Endpoint network interfaces |
| `nsg-workload` | Explicit inbound Internet deny rule | Network security for the workload subnet |

The workload subnet is associated with `nsg-workload`. Azure's default inbound deny rule also remains in effect.

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

The workload identity can read secrets from this Key Vault without using a stored client secret. No secret values were provisioned as part of this project stage.

### Azure Service Bus

- Namespace: `sb-tf-infra-c7c86f`
- SKU: Standard
- Queue: `q-work-items`
- Local SAS authentication: disabled
- Minimum TLS version: 1.2

The workload Managed Identity has the following queue-scoped roles:

- `Azure Service Bus Data Sender`
- `Azure Service Bus Data Receiver`

These assignments allow message sending and receiving at the queue scope rather than granting data-plane access across the whole subscription.

Service Bus public network access remains enabled as a lab simplification. Private Link for Service Bus is not implemented in this Standard-tier stage.

### Private connectivity validation VM

- VM: `vm-kv-pe-test`
- Size: `Standard_B1s`
- Operating system: Ubuntu 24.04 LTS
- Public IP: none
- Managed Identity: `id-terraform-demo-workload`

The VM was used to verify private DNS resolution and access to Key Vault through Managed Identity. It is retained temporarily for portfolio evidence while the lab subscription remains available.

The workload subnet currently has default outbound access enabled for the VM management and validation scenario. This is a lab limitation rather than a recommended long-term production configuration. The VM incurs Azure compute and disk charges while its resources remain allocated.

The repository contains only the public SSH key used by the VM configuration. No private SSH key is committed.

## GitHub Actions and OIDC

The `Terraform CI` workflow runs on pushes to the `main` branch and can also be triggered manually.

It performs:

1. Repository checkout
2. Azure login through OpenID Connect
3. Terraform setup
4. Terraform formatting check
5. Terraform initialization
6. Terraform validation
7. Terraform plan

The Microsoft Entra federated identity is associated with this repository and branch. GitHub Secrets provide the Client ID, Tenant ID, and Subscription ID. No long-lived client secret or Storage Account access key is stored in GitHub.

The GitHub Actions identity has read access to Azure resources for planning and `Storage Blob Data Contributor` access to the Terraform state container.

The workflow does not run `terraform apply`. Infrastructure changes are applied locally after reviewing the plan.

## Security considerations

- Azure RBAC protects access to the Terraform state container.
- Anonymous public blob access is disabled.
- The Storage Account is configured to require TLS 1.2 or later.
- Public network access to the state Storage Account remains enabled for this lab.
- Key Vault public network access is disabled and private connectivity is provided through Private Endpoint.
- Key Vault uses Azure RBAC, soft delete, and purge protection.
- The workload NSG explicitly denies inbound Internet traffic.
- The validation VM has no public IP.
- The validation VM's subnet currently has default outbound access enabled for lab diagnostics.
- Service Bus local SAS authentication is disabled; its public network access remains enabled.
- GitHub-to-Azure authentication uses OIDC rather than a long-lived client secret.
- The GitHub Actions identity cannot apply infrastructure changes.

For a production implementation, review private connectivity and egress controls for all relevant resources, restrict public network access where applicable, and evaluate operational monitoring, recovery requirements, and resource costs.

## Evidence and screenshots

Screenshots are stored in `docs/screenshots/`. They preserve evidence of the deployed architecture and successful validation independently of the Azure subscription.

| Screenshot | Evidence |
|---|---|
| [Remote state storage](docs/screenshots/01-remote-state-storage.png) | Storage Account and Terraform state blob listing |
| [VNet and subnets](docs/screenshots/02-vnet-subnets.png) | VNet address space and subnet ranges |
| [Network security group](docs/screenshots/03-nsg-inbound-rule.png) | Explicit inbound Internet deny rule |
| [Key Vault networking](docs/screenshots/04-key-vault-private-networking.png) | Public network access disabled |
| [Private Endpoint](docs/screenshots/05-private-endpoint-approved.png) | Successful provisioning and approved connection |
| [Private DNS record](docs/screenshots/06-private-dns-record.png) | Key Vault private A record |
| [Managed Identity](docs/screenshots/07-managed-identity-overview.png) | User-assigned workload identity |
| [Key Vault RBAC](docs/screenshots/08-key-vault-rbac.png) | `Key Vault Secrets User` role assignment |
| [Service Bus namespace and queue](docs/screenshots/09-servicebus-namespace-queue.png) | Standard namespace and work queue |
| [Service Bus queue RBAC](docs/screenshots/10-servicebus-queue-rbac.png) | Sender and Receiver roles at queue scope |
| [Validation VM](docs/screenshots/11-test-vm-no-public-ip.png) | VM without a public IP |
| [Private connectivity test](docs/screenshots/12-private-connectivity-test.png) | DNS, Managed Identity, and HTTP 200 test result |
| [Terraform plan](docs/screenshots/13-terraform-no-changes.png) | Terraform state matches the configuration |
| [GitHub Actions](docs/screenshots/14-github-actions-success.png) | Successful CI workflow |

Screenshots demonstrate the actual resources and checks completed in the lab. They do not contain access tokens, passwords, private keys, or Terraform state contents.

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
├── private_endpoint.tf
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
- An Azure subscription
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

Review the full plan before applying changes. Apply only when the changes are understood and expected:

```powershell
terraform apply
```

The validation VM is enabled by default in the current lab configuration so that Terraform and GitHub Actions agree with the deployed resources. Its public key is read from `assets/azure-terraform-kv-pe-test.pub`.

## Cost and lifecycle

Azure resources can incur charges even when they are not actively used. The current environment includes a Standard_B1s VM, managed disks, a Service Bus Standard namespace, a Private Endpoint, and other resources whose applicable charges depend on the resource type, duration, and usage.

The resources are being retained temporarily for evidence collection before the original lab subscription becomes unavailable. Review Azure Cost Management and the relevant pricing information before extending the environment or recreating it in another subscription.

## Recovery and portability

The GitHub repository preserves the Terraform source code, workflow, public test key, and evidence independently of the original subscription.

If the original subscription becomes unavailable, deployment into another subscription requires a valid target subscription, a usable state backend, appropriate permissions, and a deliberate backend configuration. Azure resources and Terraform state do not automatically transfer to another subscription.

Do not reuse an old state file blindly in a different subscription. Review the target environment and establish the backend deliberately.

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
- Security documentation, technical evidence, and cost-aware lab design
