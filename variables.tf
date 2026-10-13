variable "location" {
  description = "Azure region for the Terraform demo resources"
  type        = string
  default     = "West Europe"
}

variable "key_vault_name" {
  description = "Globally unique name of the Azure Key Vault"
  type        = string
  default     = "kv-tf-infra-c7c86f"
}