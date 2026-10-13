terraform {
  backend "azurerm" {
    use_cli          = true
    use_azuread_auth = true

    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateivanov2026"
    container_name       = "tfstate"
    key                  = "azure-terraform-infrastructure.tfstate"
  }
}