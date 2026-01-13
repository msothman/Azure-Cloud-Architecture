# Staging Environment Configuration
# Production-like settings for integration testing and UAT

# Project Configuration
project_name   = "cloudarch"
project_short  = "cloudarch"
environment    = "staging"
location       = "uksouth"
location_short = "uks"

# Networking - Production-like network
vnet_address_space       = "10.1.0.0/16"
web_subnet_prefix        = "10.1.1.0/24"
app_subnet_prefix        = "10.1.2.0/24"
data_subnet_prefix       = "10.1.3.0/24"
management_subnet_prefix = "10.1.4.0/24"

# Compute - Moderate resources for staging
web_vm_count   = 2
web_vm_size    = "Standard_B2s"
app_vm_size    = "Standard_B2s"
admin_username = "azureadmin"
os_disk_type   = "StandardSSD_LRS"

# Storage - Local redundancy acceptable for staging
storage_replication_type  = "LRS"
enable_storage_versioning = true

# Database - Standard tier for realistic testing
database_sku         = "S0"
database_max_size_gb = 10

# Security - Moderate retention for staging
log_retention_days    = 30
alert_email_addresses = []

# Tags
owner       = "Mohammad Othman"
cost_center = "Learning"
