# Compute Module - Outputs

output "web_vm_ids" {
  description = "IDs of web virtual machines"
  value       = azurerm_linux_virtual_machine.web[*].id
}

output "web_vm_names" {
  description = "Names of web virtual machines"
  value       = azurerm_linux_virtual_machine.web[*].name
}

output "web_vm_private_ips" {
  description = "Private IP addresses of web VMs"
  value       = azurerm_network_interface.web[*].private_ip_address
}

output "web_vm_identities" {
  description = "Managed identity principal IDs for web VMs"
  value       = azurerm_linux_virtual_machine.web[*].identity[0].principal_id
}

output "app_vm_id" {
  description = "ID of application virtual machine"
  value       = azurerm_linux_virtual_machine.app.id
}

output "app_vm_name" {
  description = "Name of application virtual machine"
  value       = azurerm_linux_virtual_machine.app.name
}

output "app_vm_private_ip" {
  description = "Private IP address of application VM"
  value       = azurerm_network_interface.app.private_ip_address
}

output "app_vm_identity" {
  description = "Managed identity principal ID for application VM"
  value       = azurerm_linux_virtual_machine.app.identity[0].principal_id
}

output "availability_set_id" {
  description = "ID of the web availability set"
  value       = azurerm_availability_set.web.id
}
