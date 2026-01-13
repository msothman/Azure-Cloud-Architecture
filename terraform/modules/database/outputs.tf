# Database Module - Outputs

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_admin_username" {
  description = "SQL Server administrator username"
  value       = var.sql_admin_username
}

output "sql_admin_password" {
  description = "SQL Server administrator password"
  value       = random_password.sql_admin.result
  sensitive   = true
}

output "sql_connection_string" {
  description = "SQL Database connection string template"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

output "sql_server_identity" {
  description = "Managed identity principal ID for SQL Server"
  value       = azurerm_mssql_server.main.identity[0].principal_id
}
