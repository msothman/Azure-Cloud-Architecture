# Networking Module - Outputs

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = azurerm_subnet.data.id
}

output "management_subnet_id" {
  description = "ID of the management subnet"
  value       = azurerm_subnet.management.id
}

output "web_nsg_id" {
  description = "ID of the web network security group"
  value       = azurerm_network_security_group.web.id
}

output "app_nsg_id" {
  description = "ID of the application network security group"
  value       = azurerm_network_security_group.app.id
}

output "data_nsg_id" {
  description = "ID of the data network security group"
  value       = azurerm_network_security_group.data.id
}

output "lb_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "lb_backend_pool_id" {
  description = "ID of the load balancer backend pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "lb_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "lb_public_ip_id" {
  description = "ID of the load balancer public IP"
  value       = azurerm_public_ip.lb.id
}
