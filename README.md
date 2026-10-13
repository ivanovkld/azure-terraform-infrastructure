# azure-terraform-infrastructure

Hands-on Azure infrastructure project using Terraform, Microsoft Entra ID, RBAC and GitHub Actions



\## Project Status

Initial project setup.



\## Network foundation



\*\*Region:\*\* West Europe  

\*\*Resource group:\*\* `rg-terraform-demo`



\### Architecture



\- Virtual network: `vnet-terraform-demo`

&#x20; - Address space: `10.20.0.0/16`

\- Workload subnet: `snet-workload`

&#x20; - Address range: `10.20.1.0/24`

&#x20; - Associated NSG: `nsg-workload`

\- Private endpoints subnet: `snet-private-endpoints`

&#x20; - Address range: `10.20.2.0/24`

&#x20; - Reserved for future private connectivity to Azure PaaS services



\### Network security



The workload NSG includes an explicit deny rule for inbound traffic from the public Internet. Azure's default inbound deny rule also remains in effect.



No virtual machines, public IP addresses, NAT Gateway, or Private Endpoints are deployed in this stage.



\### Terraform and CI



\- The root Terraform configuration uses an Azure Blob Storage remote backend.

\- Bootstrap resources are maintained in a separate Terraform configuration.

\- GitHub Actions authenticates to Azure through Microsoft Entra ID OIDC.

\- The GitHub Actions workflow runs formatting checks, validation, and `terraform plan`.

\- Infrastructure changes are applied locally after reviewing the plan.



\### Cost and limitations



This stage establishes the network foundation without deploying compute resources or paid network endpoints. Future Private Endpoints and Azure PaaS services will be assessed separately for cost and security requirements.

