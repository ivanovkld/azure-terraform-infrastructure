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

output "servicebus_namespace_name" {
  description = "Name of the Azure Service Bus namespace"
  value       = azurerm_servicebus_namespace.demo.name
}

output "servicebus_namespace_id" {
  description = "Resource ID of the Azure Service Bus namespace"
  value       = azurerm_servicebus_namespace.demo.id
}

output "servicebus_queue_name" {
  description = "Name of the workload message queue"
  value       = azurerm_servicebus_queue.work_items.name
}

output "servicebus_queue_id" {
  description = "Resource ID of the workload message queue"
  value       = azurerm_servicebus_queue.work_items.id
}

output "private_endpoints_subnet_id" {
  description = "Resource ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "network_security_group_name" {
  description = "Name of the workload network security group"
  value       = azurerm_network_security_group.workload.name
}

output "key_vault_name" {
  description = "Name of the project's Azure Key Vault"
  value       = azurerm_key_vault.demo.name
}

output "key_vault_uri" {
  description = "URI of the project's Azure Key Vault"
  value       = azurerm_key_vault.demo.vault_uri
}

output "workload_managed_identity_name" {
  description = "Name of the workload user-assigned managed identity"
  value       = azurerm_user_assigned_identity.workload.name
}

output "workload_managed_identity_client_id" {
  description = "Client ID of the workload user-assigned managed identity"
  value       = azurerm_user_assigned_identity.workload.client_id
}

output "workload_managed_identity_principal_id" {
  description = "Principal ID used for Azure RBAC assignments"
  value       = azurerm_user_assigned_identity.workload.principal_id
}