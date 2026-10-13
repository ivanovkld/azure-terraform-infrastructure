resource "azurerm_servicebus_namespace" "demo" {
  name                = var.servicebus_namespace_name
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  sku = "Standard"

  local_auth_enabled            = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = local.common_tags
}

resource "azurerm_servicebus_queue" "work_items" {
  name         = "q-work-items"
  namespace_id = azurerm_servicebus_namespace.demo.id
}

resource "azurerm_role_assignment" "workload_servicebus_sender" {
  scope                = azurerm_servicebus_queue.work_items.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  description = "Allow the workload managed identity to send messages to q-work-items."
}

resource "azurerm_role_assignment" "workload_servicebus_receiver" {
  scope                = azurerm_servicebus_queue.work_items.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  description = "Allow the workload managed identity to receive messages from q-work-items."
}