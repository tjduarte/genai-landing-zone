resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.virtual_network.name}-${var.resource_suffix}"
  location            = azurerm_resource_group.network_resource_group.location
  resource_group_name = azurerm_resource_group.network_resource_group.name
  address_space       = var.virtual_network.address_space
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "ai_subnet" {
  name                 = "ai-subnet"
  resource_group_name  = azurerm_resource_group.network_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.virtual_network.subnets.ai]

  service_endpoints = [
    "Microsoft.CognitiveServices",
    "Microsoft.Storage"
  ]
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "apim-subnet"
  resource_group_name  = azurerm_resource_group.network_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.virtual_network.subnets.apim]

  service_endpoints = [
    "Microsoft.CognitiveServices",
    "Microsoft.Storage"
  ]

  delegation {
    name = "Microsoft.Web.serverFarms"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.network_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.virtual_network.subnets.vm]

  service_endpoints = [
    "Microsoft.CognitiveServices",
    "Microsoft.Storage"
  ]
}
