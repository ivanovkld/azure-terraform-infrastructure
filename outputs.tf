output "resource_group_name" {
  description = "Name of the Terraform-managed resource group"
  value       = azurerm_resource_group.demo.name
}