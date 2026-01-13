# Production Environment Configuration
# High availability and security settings for production workloads

# Project Configuration
project_name   = "cloudarch"
project_short  = "cloudarch"
environment    = "prod"
location       = "uksouth"
location_short = "uks"

# Networking - Production network with larger address space
vnet_address_space       = "10.2.0.0/16"
web_subnet_prefix        = "10.2.1.0/24"
app_subnet_prefix        = "10.2.2.0/24"
data_subnet_prefix       = "10.2.3.0/24"
management_subnet_prefix = "10.2.4.0/24"

# Compute - Production-grade resources
web_vm_count   = 2
web_vm_size    = "Standard_D2s_v3"
app_vm_size    = "Standard_D2s_v3"
admin_username = "azureadmin"
os_disk_type   = "Premium_LRS"

# Storage - Geo-redundant for disaster recovery
storage_replication_type  = "GRS"
enable_storage_versioning = true

# Database - Standard tier with higher performance
database_sku         = "S1"
database_max_size_gb = 50

# Security - Extended retention for compliance
log_retention_days    = 90
alert_email_addresses = []

# Tags
owner       = "Mohammad Othman"
cost_center = "Learning"
