# Security Module - Main Configuration
# Provides Key Vault, Log Analytics, and Azure Monitor resources

# Data source for current client
data "azurerm_client_config" "current" {}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project_name}-${var.environment}-${var.location_short}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.project_name}-${var.environment}-${random_string.kv_suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = var.environment == "prod" ? true : false
  sku_name                    = "standard"

  enable_rbac_authorization = true

  network_acls {
    bypass         = "AzureServices"
    default_action = var.enable_network_rules ? "Deny" : "Allow"
    ip_rules       = var.allowed_ip_ranges
  }

  tags = var.tags
}

resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Key Vault Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-keyvault"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Role Assignment - Current User as Key Vault Administrator
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Role Assignment - VMs as Key Vault Secrets User
resource "azurerm_role_assignment" "vm_kv_access" {
  for_each             = toset(var.vm_principal_ids)
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

# Store SQL Admin Password in Key Vault
resource "azurerm_key_vault_secret" "sql_password" {
  count        = var.sql_admin_password != "" ? 1 : 0
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Store Storage Connection String in Key Vault
resource "azurerm_key_vault_secret" "storage_connection" {
  count        = var.storage_connection_string != "" ? 1 : 0
  name         = "storage-connection-string"
  value        = var.storage_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.project_name}-${var.environment}-001"
  resource_group_name = var.resource_group_name
  short_name          = substr("ag${var.environment}", 0, 12)

  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Metric Alert - High CPU
resource "azurerm_monitor_metric_alert" "high_cpu" {
  count               = length(var.vm_ids) > 0 ? 1 : 0
  name                = "alert-high-cpu-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_ids
  description         = "Alert when CPU usage exceeds 80%"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Metric Alert - Low Disk Space
resource "azurerm_monitor_metric_alert" "low_disk" {
  count               = length(var.vm_ids) > 0 ? 1 : 0
  name                = "alert-low-disk-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_ids
  description         = "Alert when available disk space is low"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Queue Depth"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Activity Log Alert - Resource Health
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  name                = "alert-resource-health-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.resource_group_id]
  description         = "Alert on resource health events"

  criteria {
    category = "ResourceHealth"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}
