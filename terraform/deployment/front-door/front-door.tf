resource "azurerm_cdn_frontdoor_profile" "frontdoor_profile" {
  name                     = "${var.name}-${var.resource_suffix}"
  resource_group_name      = var.resource_group
  sku_name                 = "Standard_AzureFrontDoor"
  tags                     = var.tags
  response_timeout_seconds = 60
}

resource "azurerm_cdn_frontdoor_endpoint" "frontdoor_endpoint" {
  name                     = "apim-gateway"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "frontdoor_origin_group" {
  name                     = "apim-origingroup"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor_profile.id
  session_affinity_enabled = false

  health_probe {
    interval_in_seconds = 30
    path                = "/status-0123456789abcdef"
    protocol            = "Https"
    request_type        = "GET"
  }

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "frontdoor_origin" {
  name                           = "apim-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group.id
  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = var.apim_host_name
  origin_host_header             = var.apim_host_name
  http_port                      = 80
  https_port                     = 443
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "frontdoor_route" {
  name                          = "apim-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontdoor_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontdoor_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontdoor_origin.id]
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cache {
    query_string_caching_behavior = "UseQueryString"
  }
}
