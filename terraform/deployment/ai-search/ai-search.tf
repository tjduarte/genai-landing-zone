resource "azurerm_search_service" "ai_search" {
  name                          = "${var.name}-${var.resource_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group
  sku                           = "standard2"
  semantic_search_sku           = "free"
  replica_count                 = 1
  public_network_access_enabled = true
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone" "search_private_dns_zone" {
  name                = "search.windows.net"
  resource_group_name = var.network_resource_group
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "search_private_dns_zone_link" {
  name                  = "${var.name}-private-dns-zone-link"
  resource_group_name   = var.network_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.search_private_dns_zone.name
  virtual_network_id    = var.virtual_network.id
  tags                  = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "search_private_endpoint" {
  name                          = "pi-${var.name}-${var.resource_suffix}"
  location                      = var.location
  resource_group_name           = var.network_resource_group
  subnet_id                     = var.virtual_network.subnet_id
  custom_network_interface_name = "ni-${var.name}-${var.resource_suffix}"
  tags                          = var.tags

  private_service_connection {
    name                           = "${var.name}-private-service-connection"
    private_connection_resource_id = azurerm_search_service.ai_search.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink"
    private_dns_zone_ids = [azurerm_private_dns_zone.search_private_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
