locals {
  common_tags = {
    project     = "azure-terraform-infrastructure"
    environment = "lab"
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "demo" {
  name     = "rg-terraform-demo"
  location = var.location

  tags = local.common_tags
}