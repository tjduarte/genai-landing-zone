output "id" {
  value = azapi_resource.api_management.id
}

output "system_identity_id" {
  value = azapi_resource.api_management.identity[0].principal_id
}