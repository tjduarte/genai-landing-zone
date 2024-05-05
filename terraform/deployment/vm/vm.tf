resource "azurerm_public_ip" "vm_public_ip" {
  name                = "pip-${var.name}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.network_resource_group
  allocation_method   = "Static"
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-${var.name}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.network_resource_group
  tags                = var.tags

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [tags]
  }

}

resource "azurerm_network_interface" "vm_nic" {
  name                = "ni-${var.name}-${var.resource_suffix}"
  location            = var.location
  resource_group_name = var.network_resource_group
  tags                = var.tags

  ip_configuration {
    name                          = "nic-configuration"
    subnet_id                     = var.virtual_network.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_windows_virtual_machine" "virtual_machine" {
  name                  = "${var.name}-${var.resource_suffix}"
  computer_name         = substr(replace("${var.name}-${var.resource_suffix}", "-", ""), 0, 15)
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = "Standard_DS2_v2"
  tags                  = var.tags

  os_disk {
    name                 = replace("${var.name}-${var.resource_suffix}", "-", "")
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "virtual_machine_shutdown_schedule" {
  virtual_machine_id = azurerm_windows_virtual_machine.virtual_machine.id
  location           = azurerm_windows_virtual_machine.virtual_machine.location
  enabled            = true
  notification_settings {
    enabled = false
  }
  daily_recurrence_time = "1900"
  timezone              = "UTC"
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}
