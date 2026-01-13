# Root Module - Variables
# Defines all input variables for the infrastructure

# Project Configuration
variable "project_name" {
  description = "Name of the project used in resource naming"
  type        = string
  default     = "cloudarch"
}

variable "project_short" {
  description = "Short project name for storage accounts (max 10 chars, no hyphens)"
  type        = string
  default     = "cloudarch"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "swedencentral"
}

variable "location_short" {
  description = "Short form of Azure region"
  type        = string
  default     = "swc"
}

# Networking Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_prefix" {
  description = "Address prefix for web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_prefix" {
  description = "Address prefix for application subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "data_subnet_prefix" {
  description = "Address prefix for data subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "management_subnet_prefix" {
  description = "Address prefix for management subnet"
  type        = string
  default     = "10.0.4.0/24"
}

# Compute Configuration
variable "web_vm_count" {
  description = "Number of web VMs to deploy"
  type        = number
  default     = 2
}

variable "web_vm_size" {
  description = "Size of web VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "app_vm_size" {
  description = "Size of application VM"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username for VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
  sensitive   = true
}

variable "os_disk_type" {
  description = "Type of OS disk for VMs"
  type        = string
  default     = "StandardSSD_LRS"
}

# Storage Configuration
variable "storage_replication_type" {
  description = "Storage replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "enable_storage_versioning" {
  description = "Enable blob versioning on storage account"
  type        = bool
  default     = true
}

# Database Configuration
variable "database_sku" {
  description = "SKU for Azure SQL Database"
  type        = string
  default     = "Basic"
}

variable "database_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 2
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
}

variable "aad_admin_username" {
  description = "Azure AD administrator username for SQL"
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD administrator object ID for SQL"
  type        = string
}

# Security Configuration
variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "alert_email_addresses" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
}

# Tagging
variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Mohammad Othman"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "Learning"
}

# Common tags applied to all resources
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  }
}
