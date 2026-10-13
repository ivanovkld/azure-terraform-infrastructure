output "resource_group_name" {
  description = "Name of the Terraform-managed resource group"
  value       = azurerm_resource_group.demo.name
}

output "virtual_network_name" {
  description = "Name of the project's virtual network"
  value       = azurerm_virtual_network.demo.name
}

output "virtual_network_id" {
  description = "Resource ID of the project's virtual network"
  value       = azurerm_virtual_network.demo.id
}

output "workload_subnet_id" {
  description = "Resource ID of the workload subnet"
  value       = azurerm_subnet.workload.id
}

output "private_endpoints_subnet_id" {
  description = "Resource ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "network_security_group_name" {
  description = "Name of the workload network security group"
  value       = azurerm_network_security_group.workload.name
}