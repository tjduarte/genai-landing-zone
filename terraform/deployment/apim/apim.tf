data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "azapi_resource" "api_management" {
  type      = "Microsoft.ApiManagement/service@2023-05-01-preview"
  name      = "${var.name}-${var.resource_suffix}"
  location  = var.location
  parent_id = data.azurerm_resource_group.resource_group.id
  tags      = var.tags
  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {
      publisherEmail = "tiago.duarte@stellium.consulting"
      publisherName  = "Stellium SA"
      virtualNetworkConfiguration = {
        subnetResourceId = var.virtual_network.subnet_id
      }
      virtualNetworkType = "External"
    }
    sku = {
      capacity = 1
      name     = "StandardV2"
    }
  })
}

data "azuread_service_principal" "api_management_system_identity" {
  object_id = azapi_resource.api_management.identity[0].principal_id
}

resource "azapi_resource" "backends" {
  type      = "Microsoft.ApiManagement/service/backends@2023-05-01-preview"
  for_each  = { for idx, openai_uri in var.openai_uris : idx => openai_uri }
  name      = "openai-backend-${each.key}"
  parent_id = azapi_resource.api_management.id
  body = jsonencode({
    properties = {
      description = "openai-backend"
      protocol    = "http"
      tls = {
        validateCertificateChain = true
        validateCertificateName  = true
      }
      url = "${each.value}openai/"
    }
  })
}

resource "azapi_resource" "api_import" {
  type      = "Microsoft.ApiManagement/service/apis@2023-05-01-preview"
  parent_id = azapi_resource.api_management.id
  name      = "azure-openai-service-api"
  body = jsonencode({
    properties = {
      path        = "openai"
      apiRevision = "1"
      displayName = "Azure OpenAI Service API"
      protocols   = ["https"]
      format      = "openapi+json"
      value       = jsonencode(local.api_schema)
    }
  })
}

resource "azapi_resource" "api_policies" {
  type      = "Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview"
  name      = "policy"
  parent_id = azapi_resource.api_import.id
  body = jsonencode({
    properties = {
      format = "rawxml"
      value  = file("${path.module}/policies/policies.txt")
    }
  })
}

# resource "azurerm_api_management_named_value" "uami_client_id" {
#   name                = "uami-client-id"
#   resource_group_name = var.resource_group
#   api_management_name = azapi_resource.api_management.name
#   display_name        = "uami-client-id"
#   value               = data.azuread_service_principal.api_management_system_identity.client_id
# }
