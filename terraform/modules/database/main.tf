# Database Module - Main Configuration
# Provides Azure SQL Database with security and backup configuration

# Generate random password for SQL Admin
resource "random_password" "sql_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "sql-${var.project_name}-${var.environment}-${var.location_short}-001"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_admin.result
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username              = var.aad_admin_username
    object_id                   = var.aad_admin_object_id
    azuread_authentication_only = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name                 = "sqldb-${var.project_name}-${var.environment}-001"
  server_id            = azurerm_mssql_server.main.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = var.database_max_size_gb
  sku_name             = var.database_sku
  zone_redundant       = var.zone_redundant
  storage_account_type = var.backup_storage_type

  short_term_retention_policy {
    retention_days           = var.short_term_retention_days
    backup_interval_in_hours = 12
  }

  tags = var.tags
}

# Firewall Rule - Allow Azure Services
resource "azurerm_mssql_firewall_rule" "allow_azure" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Virtual Network Rule - Allow from Data Subnet
resource "azurerm_mssql_virtual_network_rule" "data_subnet" {
  name      = "allow-data-subnet"
  server_id = azurerm_mssql_server.main.id
  subnet_id = var.data_subnet_id
}

# Threat Detection Policy
resource "azurerm_mssql_server_security_alert_policy" "main" {
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mssql_server.main.name
  state               = "Enabled"

  email_account_admins = true
  email_addresses      = var.security_alert_emails

  retention_days = 30
}
