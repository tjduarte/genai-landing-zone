resource "azurerm_cognitive_account" "open_ai" {
  name                       = "${var.name}${var.index}-${var.resource_suffix}"
  location                   = var.oai_location
  resource_group_name        = var.resource_group
  kind                       = "OpenAI"
  sku_name                   = "S0"
  tags                       = var.tags
  custom_subdomain_name      = "${var.name}${var.index}-${var.resource_suffix}"
  dynamic_throttling_enabled = false

  network_acls {
    default_action = "Deny"
    ip_rules       = []
    virtual_network_rules {
      ignore_missing_vnet_service_endpoint = false
      subnet_id                            = var.virtual_network.subnet_id
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_cognitive_deployment" "open_ai_deployments" {
  for_each = {
    for idx, deployment in var.deployments : deployment.name => deployment
  }
  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.open_ai.id

  model {
    format  = "OpenAI"
    name    = each.value.model
    version = each.value.version
  }

  scale {
    type     = "Standard"
    capacity = each.value.capacity
  }
}

resource "azurerm_private_endpoint" "oai_private_endpoint" {
  name                          = "pi-${var.name}${var.index}-${var.resource_suffix}"
  location                      = var.location
  resource_group_name           = var.network_resource_group
  subnet_id                     = var.virtual_network.subnet_id
  custom_network_interface_name = "ni-${var.name}${var.index}-${var.resource_suffix}"
  tags                          = var.tags

  private_service_connection {
    name                           = "${var.name}${var.index}-private-service-connection"
    private_connection_resource_id = azurerm_cognitive_account.open_ai.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink"
    private_dns_zone_ids = [var.private_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
