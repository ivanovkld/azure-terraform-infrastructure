variable "location" {
  description = "Azure region for the Terraform state backend"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the Terraform state backend"
  type        = string
  default     = "rg-tfstate"
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name"
  type        = string
}