# Development Environment Configuration
# Cost-optimised settings for development and testing

# Project Configuration
project_name   = "cloudarch"
project_short  = "cloudarch"
environment    = "dev"
location       = "swedencentral"
location_short = "swc"

# Networking - Standard development network
vnet_address_space       = "10.0.0.0/16"
web_subnet_prefix        = "10.0.1.0/24"
app_subnet_prefix        = "10.0.2.0/24"
data_subnet_prefix       = "10.0.3.0/24"
management_subnet_prefix = "10.0.4.0/24"

# Compute - Minimal resources for dev
web_vm_count   = 1
web_vm_size    = "Standard_B2s_v2"
app_vm_size    = "Standard_B2s_v2"
admin_username = "azureadmin"
os_disk_type   = "Standard_LRS"

# Storage - Local redundancy for cost savings
storage_replication_type  = "LRS"
enable_storage_versioning = false

# Database - Basic tier for development
database_sku         = "Basic"
database_max_size_gb = 2

# Security - Minimum 30 days for free tier
log_retention_days    = 30
alert_email_addresses = []

# Azure AD Admin for SQL
aad_admin_username  = "MOHAMMAD OTHMAN"
aad_admin_object_id = "60467508-55ce-406d-ade0-6e0b718c844f"

# SSH Key for VM access
admin_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDA7gsoJuTZFUnM1Wy3LZCiOSIpesDNBVnujz1uyrE3S3CAD/3uLD6UuP+dMqmhoAEeJ0GHa9++rPwNRFru5oGVy/dUoS+OjyQNSamkkwTbAKT5oVqnvgIU/mtZP+R8u1EU0DlffSI5z3J7/2HTbrf3CwypaP76Ruuu72y0/LrhWpGMFGn/zXrR2DBrFVI9OeCun8AKIqipfaScz/LIHrvpnL8avl3LBVkQ82kfO46xVJNgNN6CdVEjmGse9gegrYM4XdGU12VjR2wqyM08tEjHNs5WLpFWQ8RdU85kn7LbMxdfF7t1mmVK/5DgB4YwZZPYDFTOskZKHfIGobCH7G6ZjHoplXjynVZeS7yPlIdjrYe3DX8k03l9rnSPpNwvPyHY4Z3rJJIwRdomdwWUeBoUMCNQm8u6fWTOkANNhFEOZ2JQcRRcdq/lSCqIiwQg8UPIN85RmqWp2Dgd608G7WPRNW077bm4DvIfSImE6bgVmTxT2fb4tufqPl5+Ft+mIwjcUFSqkuEOHYKrke+OTZVMGEsGb1dMrWNq+9HTR21wT/jctTjwkUZqBGSO6aDHF/FCeRDixK5gEWuX7ieAN/l65nem4DgS0b4fVhnWTnD+tNUHkIOt0ZhQLhV1StfUemtqDvhgZdaHNObjL11nZkf3v/nIJhSoFfEXQQDduckG3Q== i34tu@ls"

# Tags
owner       = "Mohammad Othman"
cost_center = "Learning"
