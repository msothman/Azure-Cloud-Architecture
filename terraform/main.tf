# Root Module - Main Configuration
# Orchestrates all infrastructure modules for Azure Cloud Architecture

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location_short}-001"
  location = var.location

  tags = local.common_tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name             = var.project_name
  environment              = var.environment
  location                 = var.location
  location_short           = var.location_short
  resource_group_name      = azurerm_resource_group.main.name
  vnet_address_space       = var.vnet_address_space
  web_subnet_prefix        = var.web_subnet_prefix
  app_subnet_prefix        = var.app_subnet_prefix
  data_subnet_prefix       = var.data_subnet_prefix
  management_subnet_prefix = var.management_subnet_prefix

  tags = local.common_tags
}

# Security Module (deployed early - Log Analytics needed by other modules)
module "security" {
  source = "./modules/security"

  project_name          = var.project_name
  environment           = var.environment
  location              = var.location
  location_short        = var.location_short
  resource_group_name   = azurerm_resource_group.main.name
  resource_group_id     = azurerm_resource_group.main.id
  log_retention_days    = var.log_retention_days
  alert_email_addresses = var.alert_email_addresses
  # VM info passed after compute module creates VMs
  vm_principal_ids = []
  vm_ids           = []
  # Secrets stored after initial deployment to avoid circular dependency
  sql_admin_password        = ""
  storage_connection_string = ""

  tags = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_name               = var.project_name
  project_short              = var.project_short
  environment                = var.environment
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  data_subnet_id             = module.networking.data_subnet_id
  account_tier               = "Standard"
  replication_type           = var.storage_replication_type
  enable_versioning          = var.enable_storage_versioning
  enable_network_rules       = false
  log_analytics_workspace_id = ""

  tags = local.common_tags

  depends_on = [module.networking]
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  location_short       = var.location_short
  resource_group_name  = azurerm_resource_group.main.name
  web_subnet_id        = module.networking.web_subnet_id
  app_subnet_id        = module.networking.app_subnet_id
  lb_backend_pool_id   = module.networking.lb_backend_pool_id
  web_vm_count         = var.web_vm_count
  web_vm_size          = var.web_vm_size
  app_vm_size          = var.app_vm_size
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  os_disk_type         = var.os_disk_type

  tags = local.common_tags

  depends_on = [module.networking]
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name              = var.project_name
  environment               = var.environment
  location                  = var.location
  location_short            = var.location_short
  resource_group_name       = azurerm_resource_group.main.name
  data_subnet_id            = module.networking.data_subnet_id
  sql_admin_username        = var.sql_admin_username
  aad_admin_username        = var.aad_admin_username
  aad_admin_object_id       = var.aad_admin_object_id
  database_sku              = var.database_sku
  database_max_size_gb      = var.database_max_size_gb
  zone_redundant            = var.environment == "prod" ? true : false
  backup_storage_type       = var.environment == "prod" ? "Geo" : "Local"
  short_term_retention_days = var.environment == "prod" ? 35 : 7
  security_alert_emails     = var.alert_email_addresses

  tags = local.common_tags

  depends_on = [module.networking]
}
