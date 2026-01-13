# Networking Module - Variables

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
  description = "Address prefix for management/bastion subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
