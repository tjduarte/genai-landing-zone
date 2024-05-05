resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group.name}-${var.resource_suffix}"
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_resource_group" "network_resource_group" {
  name     = "${var.network_resource_group.name}-${var.resource_suffix}"
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}
