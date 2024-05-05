resource "azurerm_private_dns_zone" "oai_private_dns_zone" {
  name                = "openai.azure.com"
  resource_group_name = azurerm_resource_group.network_resource_group.name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

module "open_ai" {
  source = "./open-ai"

  for_each = { for idx, val in var.open_ai.locations : idx => val }

  location               = azurerm_resource_group.resource_group.location
  resource_group         = azurerm_resource_group.resource_group.name
  name                   = var.open_ai.name
  index                  = each.key + 1
  oai_location           = each.value
  resource_suffix        = var.resource_suffix
  network_resource_group = azurerm_resource_group.network_resource_group.name
  deployments = [
    {
      name     = "gpt_4_turbo"
      model    = "gpt-4"
      version  = "1106-Preview"
      capacity = 40
    },
    {
      name     = "ada_2"
      model    = "text-embedding-ada-002"
      version  = "2"
      capacity = 100
    }
  ]
  tags = var.tags
  virtual_network = {
    id        = azurerm_virtual_network.virtual_network.id
    subnet_id = azurerm_subnet.ai_subnet.id
  }
  private_dns_zone = {
    name = azurerm_private_dns_zone.oai_private_dns_zone.name
    id   = azurerm_private_dns_zone.oai_private_dns_zone.id
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "oai_private_dns_zone_link" {
  name                  = "${var.open_ai.name}-private-dns-zone-link"
  resource_group_name   = azurerm_resource_group.network_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.oai_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
  tags                  = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}
