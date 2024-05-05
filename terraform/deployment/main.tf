module "virtual_machine" {
  source                 = "./vm"
  location               = azurerm_resource_group.resource_group.location
  resource_group         = azurerm_resource_group.resource_group.name
  name                   = var.virtual_machine.name
  resource_suffix        = var.resource_suffix
  network_resource_group = azurerm_resource_group.network_resource_group.name
  tags                   = var.tags
  virtual_network = {
    id        = azurerm_virtual_network.virtual_network.id
    subnet_id = azurerm_subnet.vm_subnet.id
  }
}

module "storage" {
  source                 = "./storage"
  location               = azurerm_resource_group.resource_group.location
  resource_group         = azurerm_resource_group.resource_group.name
  name                   = var.storage.name
  container_name         = var.storage.container_name
  resource_suffix        = var.resource_suffix
  network_resource_group = azurerm_resource_group.network_resource_group.name
  tags                   = var.tags
  virtual_network = {
    id              = azurerm_virtual_network.virtual_network.id
    subnet_id       = azurerm_subnet.ai_subnet.id
    allowed_subnets = [azurerm_subnet.ai_subnet.id, azurerm_subnet.vm_subnet.id, azurerm_subnet.apim_subnet.id]
  }
}

module "ai_search" {
  source                 = "./ai-search"
  location               = azurerm_resource_group.resource_group.location
  resource_group         = azurerm_resource_group.resource_group.name
  name                   = var.ai_search.name
  resource_suffix        = var.resource_suffix
  network_resource_group = azurerm_resource_group.network_resource_group.name
  tags                   = var.tags
  virtual_network = {
    id        = azurerm_virtual_network.virtual_network.id
    subnet_id = azurerm_subnet.ai_subnet.id
  }
}

module "apim" {
  source                 = "./apim"
  location               = azurerm_resource_group.resource_group.location
  resource_group         = azurerm_resource_group.resource_group.name
  name                   = var.apim.name
  resource_suffix        = var.resource_suffix
  network_resource_group = azurerm_resource_group.network_resource_group.name
  tags                   = var.tags
  openai_uris            = [for open_ai in module.open_ai : open_ai.endpoint]
  virtual_network = {
    id        = azurerm_virtual_network.virtual_network.id
    subnet_id = azurerm_subnet.apim_subnet.id
  }
}

# Assign permissions to Azure AI Search system identity

resource "azurerm_role_assignment" "ai_search_to_storage" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.ai_search.system_identity_id
}

resource "azurerm_role_assignment" "ai_search_to_open_ai" {

  for_each = {
    for idx, open_ai in module.open_ai : idx => open_ai
  }

  scope                = each.value.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.ai_search.system_identity_id
}

resource "azurerm_role_assignment" "apim_to_open_ai" {

  for_each = {
    for idx, open_ai in module.open_ai : idx => open_ai
  }

  scope                = each.value.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.apim.system_identity_id
}
