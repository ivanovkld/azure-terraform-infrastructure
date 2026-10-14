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

variable "servicebus_namespace_name" {
  description = "Globally unique Azure Service Bus namespace name"
  type        = string
  default     = "sb-tf-infra-c7c86f"
}

variable "enable_private_endpoint_test_vm" {
  description = "Keep the private endpoint validation VM deployed while the lab subscription is active"
  type        = bool
  default     = true
}