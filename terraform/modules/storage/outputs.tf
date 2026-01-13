# Storage Module - Outputs

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "uploads_container_name" {
  description = "Name of uploads container"
  value       = azurerm_storage_container.uploads.name
}

output "backups_container_name" {
  description = "Name of backups container"
  value       = azurerm_storage_container.backups.name
}

output "logs_container_name" {
  description = "Name of logs container"
  value       = azurerm_storage_container.logs.name
}

output "storage_account_identity" {
  description = "Managed identity principal ID for storage account"
  value       = azurerm_storage_account.main.identity[0].principal_id
}
