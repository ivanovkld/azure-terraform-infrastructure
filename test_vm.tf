resource "azurerm_network_interface" "private_endpoint_test" {
  count = var.enable_private_endpoint_test_vm ? 1 : 0

  name                = "nic-kv-pe-test"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "private_endpoint_test" {
  count = var.enable_private_endpoint_test_vm ? 1 : 0

  name                = "vm-kv-pe-test"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  size                = "Standard_B1s"

  admin_username                  = "azuretest"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.private_endpoint_test[0].id
  ]

  admin_ssh_key {
    username   = "azuretest"
    public_key = trimspace(file("${path.module}/assets/azure-terraform-kv-pe-test.pub"))
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.workload.id
    ]
  }

  tags = local.common_tags
}