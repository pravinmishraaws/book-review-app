locals {
  # Derive a short location slug from the full Azure region name
  location_short_map = {
    "South Africa North" = "southafricanorth"
    "South Africa West"  = "southafricawest"
    "East US"            = "eastus"
    "East US 2"          = "eastus2"
    "West US"            = "westus"
    "West US 2"          = "westus2"
    "West Europe"        = "westeurope"
    "North Europe"       = "northeurope"
    "UK South"           = "uksouth"
    "UK West"            = "ukwest"
  }
  location_short = local.location_short_map[var.location]

  # Naming Convention: project-env-location
  name_prefix = "${var.project_name}-${var.environment}-${local.location_short}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Derived names for specific resources
  vnet_name      = "${local.name_prefix}-vnet"
  db_server_name = "${var.project_name}-${var.environment}-db-server"
}