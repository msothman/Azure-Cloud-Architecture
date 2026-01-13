# Root Module - Outputs
# Exposes important values from the infrastructure deployment

# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Networking
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = module.networking.lb_public_ip
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = module.networking.web_subnet_id
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = module.networking.app_subnet_id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = module.networking.data_subnet_id
}

# Compute
output "web_vm_names" {
  description = "Names of web virtual machines"
  value       = module.compute.web_vm_names
}

output "web_vm_private_ips" {
  description = "Private IP addresses of web VMs"
  value       = module.compute.web_vm_private_ips
}

output "app_vm_name" {
  description = "Name of application virtual machine"
  value       = module.compute.app_vm_name
}

output "app_vm_private_ip" {
  description = "Private IP address of application VM"
  value       = module.compute.app_vm_private_ip
}

# Storage
output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint of storage account"
  value       = module.storage.primary_blob_endpoint
}

# Database
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.database.sql_server_name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of SQL Server"
  value       = module.database.sql_server_fqdn
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.database.sql_database_name
}

output "sql_connection_string" {
  description = "SQL Database connection string template"
  value       = module.database.sql_connection_string
  sensitive   = true
}

# Security
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.security.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "Workspace ID of the Log Analytics workspace"
  value       = module.security.log_analytics_workspace_workspace_id
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value       = <<-EOT

    ============================================================
           Azure Cloud Architecture - Deployment Summary
    ============================================================
      Environment:      ${var.environment}
      Location:         ${var.location}
      Resource Group:   ${azurerm_resource_group.main.name}
    ------------------------------------------------------------
      Web Application:  http://${module.networking.lb_public_ip}
      SQL Server:       ${module.database.sql_server_fqdn}
      Key Vault:        ${module.security.key_vault_uri}
    ============================================================

  EOT
}
