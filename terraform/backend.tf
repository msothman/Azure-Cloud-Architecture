# Terraform Backend Configuration
# Configures remote state storage in Azure Storage Account
#
# To use remote state, uncomment the backend block below and run:
# 1. Create storage account for state:
#    az storage account create --name <storage_account_name> --resource-group <rg_name> --location uksouth --sku Standard_LRS
#    az storage container create --name tfstate --account-name <storage_account_name>
# 2. terraform init -backend-config="storage_account_name=<storage_account_name>" -backend-config="container_name=tfstate" -backend-config="key=terraform.tfstate" -backend-config="resource_group_name=<rg_name>"

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "stterraformstate"
#     container_name       = "tfstate"
#     key                  = "cloudarch.terraform.tfstate"
#   }
# }

# Using local backend for demonstration
# Remove this and uncomment above for production use
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
