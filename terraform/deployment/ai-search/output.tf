output "id" {
  value = azurerm_search_service.ai_search.id
}

output "system_identity_id" {
  value = azurerm_search_service.ai_search.identity[0].principal_id
}
