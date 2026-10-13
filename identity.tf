resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-terraform-demo-workload"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  tags = local.common_tags
}

resource "azurerm_role_assignment" "workload_key_vault_secrets_user" {
  scope                = azurerm_key_vault.demo.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
  principal_type       = "ServicePrincipal"

  skip_service_principal_aad_check = true

  description = "Allow the workload managed identity to read secrets from the project Key Vault."
}