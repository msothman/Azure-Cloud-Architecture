# Compute Module - Variables

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

variable "web_subnet_id" {
  description = "ID of the web subnet"
  type        = string
}

variable "app_subnet_id" {
  description = "ID of the application subnet"
  type        = string
}

variable "lb_backend_pool_id" {
  description = "ID of the load balancer backend pool"
  type        = string
}

variable "web_vm_count" {
  description = "Number of web VMs to create"
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
  description = "Admin username for VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
}

variable "os_disk_type" {
  description = "Type of OS disk (Standard_LRS, StandardSSD_LRS, Premium_LRS)"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
