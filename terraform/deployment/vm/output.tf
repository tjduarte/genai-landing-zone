output "public_ip_address" {
  value = azurerm_windows_virtual_machine.virtual_machine.public_ip_address
}

output "admin_password" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.virtual_machine.admin_password
}
