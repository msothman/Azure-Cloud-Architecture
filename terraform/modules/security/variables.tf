# Security Module - Variables

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

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "enable_network_rules" {
  description = "Enable network rules on Key Vault"
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "vm_principal_ids" {
  description = "List of VM managed identity principal IDs for Key Vault access"
  type        = list(string)
  default     = []
}

variable "vm_ids" {
  description = "List of VM IDs for metric alerts"
  type        = list(string)
  default     = []
}

variable "sql_admin_password" {
  description = "SQL admin password to store in Key Vault"
  type        = string
  default     = ""
  sensitive   = true
}

variable "storage_connection_string" {
  description = "Storage connection string to store in Key Vault"
  type        = string
  default     = ""
  sensitive   = true
}

variable "alert_email_addresses" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
