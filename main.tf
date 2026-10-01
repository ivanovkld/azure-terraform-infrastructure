resource "azurerm_resource_group" "demo" {
  name     = "rg-terraform-demo"
  location = var.location
}