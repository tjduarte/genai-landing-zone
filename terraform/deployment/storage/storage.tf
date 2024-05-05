data "external" "ip_address" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

resource "azurerm_storage_account" "storage_account" {
  name                             = substr(replace("${var.name}${var.resource_suffix}", "-", ""), 0, 24)
  resource_group_name              = var.resource_group
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = "RAGRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  tags                             = var.tags

  network_rules {
    default_action             = "Deny"
    ip_rules                   = [data.external.ip_address.result.ip]
    virtual_network_subnet_ids = var.virtual_network.allowed_subnets
    bypass                     = ["AzureServices"]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "storage_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_private_dns_zone" "storage_private_dns_zone" {
  name                = "blob.core.windows.net"
  resource_group_name = var.network_resource_group
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_private_dns_zone_link" {
  name                  = "${var.name}-private-dns-zone-link"
  resource_group_name   = var.network_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.storage_private_dns_zone.name
  virtual_network_id    = var.virtual_network.id
  tags                  = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                          = "pi-${var.name}-${var.resource_suffix}"
  location                      = var.location
  resource_group_name           = var.network_resource_group
  subnet_id                     = var.virtual_network.subnet_id
  custom_network_interface_name = "ni-${var.name}-${var.resource_suffix}"
  tags                          = var.tags

  private_service_connection {
    name                           = "${var.name}-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_private_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
