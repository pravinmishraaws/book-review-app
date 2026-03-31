# Remote state configuration — Azure Storage backend
#
# BEFORE running `terraform init`, you must pre-create the storage account:
#
#   # 1. Create resource group for Terraform state
#   az group create --name tfstate-rg --location "South Africa North"
#
#   # 2. Create storage account (name must be globally unique, 3-24 lowercase chars)
#   az storage account create \
#     --name bookreviewch2tfstate \
#     --resource-group tfstate-rg \
#     --location "South Africa North" \
#     --sku Standard_LRS \
#     --allow-blob-public-access false
#
#   # 3. Create the blob container
#   az storage container create \
#     --name tfstate \
#     --account-name <your-unique-tfstate-sa>
#
# Then replace the placeholder values below and run:
#   terraform init          (first time — initialises with remote backend)
#   terraform init -migrate-state  (if migrating from existing local state)

terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "bookreviewch2tfstate"  # CHANGE THIS
    container_name       = "tfstate"
    key                  = "book-review-app/prod/terraform.tfstate"
  }
}
