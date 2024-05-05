output "public_ip_address" {
  value = module.virtual_machine.public_ip_address
}

output "admin_password" {
  sensitive = true
  value     = module.virtual_machine.admin_password
}
