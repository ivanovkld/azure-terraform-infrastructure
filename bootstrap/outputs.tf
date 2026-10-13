output "resource_group_name" {
  description = "Resource group containing the Terraform state storage"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account used for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "Blob container used for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}