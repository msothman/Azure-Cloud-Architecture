# Database Module - Variables

variable "project_name" {
  description = "Name of the project used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "location_short" {
  description = "Short form of Azure region (e.g., uksouth -> uks)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "data_subnet_id" {
  description = "ID of the data subnet for virtual network rule"
  type        = string
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
}

variable "aad_admin_username" {
  description = "Azure AD administrator username"
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD administrator object ID"
  type        = string
}

variable "database_sku" {
  description = "SKU for the database (Basic, S0, S1, P1, GP_S_Gen5_1, etc.)"
  type        = string
  default     = "Basic"
}

variable "database_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 2
}

variable "zone_redundant" {
  description = "Enable zone redundancy for the database"
  type        = bool
  default     = false
}

variable "backup_storage_type" {
  description = "Backup storage redundancy (Geo, Local, Zone)"
  type        = string
  default     = "Local"
}

variable "short_term_retention_days" {
  description = "Days to retain short-term backups (7-35)"
  type        = number
  default     = 7
}

variable "security_alert_emails" {
  description = "Email addresses for security alerts"
  type        = list(string)
  default     = []
}

variable "storage_account_endpoint" {
  description = "Storage account primary blob endpoint for vulnerability assessment"
  type        = string
  default     = ""
}

variable "storage_account_access_key" {
  description = "Storage account access key for vulnerability assessment"
  type        = string
  default     = ""
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "ID of Log Analytics workspace for diagnostics"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
