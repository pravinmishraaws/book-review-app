variable "project_name" {
  description = "Short name for the project, used as a prefix in all resource names"
  type        = string
  default     = "bookreview"
}

variable "environment" {
  description = "Deployment environment (e.g. prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region where all resources will be deployed"
  type        = string
  default     = "South Africa North"
}

variable "my_safe_ip" {
  description = "Your public IP address in CIDR notation for SSH access (e.g. 203.0.113.5/32)"
  type        = string
}

variable "admin_username" {
  description = "Linux admin username for the virtual machines"
  type        = string
  default     = "azureuser"
}

variable "administrator_login" {
  description = "Admin username for the MySQL Flexible Server"
  type        = string
  default     = "mysqladmin"
}

variable "db_admin_password" {
  description = "Admin password for MySQL. Never set in terraform.tfvars — use TF_VAR_db_admin_password env var"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Azure VM SKU for both frontend and backend virtual machines"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "appgw_capacity" {
  description = "Number of Application Gateway instances (min 1 for Standard_v2)"
  type        = number
  default     = 1
}

variable "repo_url" {
  description = "HTTPS URL of the Git repository to clone onto the backend VM (e.g. https://github.com/your-org/book-review-app.git)"
  type        = string
}
