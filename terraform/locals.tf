locals {
  # Naming Convention: project-env-location
  name_prefix = "${var.project_name}-${var.environment}-${var.location_short}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Derived names for specific resources
  vnet_name      = "${local.name_prefix}-vnet"
  db_server_name = "${var.project_name}-${var.environment}-db-server" # Must be unique
}