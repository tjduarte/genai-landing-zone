data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group.name}-${var.resource_suffix}"
}

data "azurerm_search_service" "ai_search" {
  name                = "${var.ai_search.name}-${var.resource_suffix}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "azurerm_storage_account" "storage_account" {
  name                = substr(replace("${var.storage.name}${var.resource_suffix}", "-", ""), 0, 24)
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "azurerm_storage_container" "storage_container" {
  name                 = var.storage.container_name
  storage_account_name = data.azurerm_storage_account.storage_account.name
}

data "azurerm_cognitive_account" "open_ai" {
  name                = "${var.open_ai.name}1-${var.resource_suffix}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
}
