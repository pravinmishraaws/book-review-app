variable "project_name" {
  type    = string
  default = "bookreview"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "South Africa North"
}

variable "location_short" {
  type    = string
  default = "southafricanorth"
}

variable "my_safe_ip" {
  description = "Your public IP for SSH and AppGateway access"
  type        = string
}

variable "admin_username" {
  description = "User name to access virtual machines"
  type        = string
  default     = "azureuser"
}

variable "administrator_login" {
  description = "Username for database login"
  type        = string
  default     = "mysqladmin"
}

variable "db_admin_password" {
  description = "Password for MySQL. Set this in terraform.tfvars"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ats_v2"
}

variable "appgw_capacity" {
  type    = number
  default = 1
}

variable "repo_url" {
  description = "HTTPS URL of the Git repository to clone onto the backend VM (e.g. https://github.com/your-org/book-review-app.git)"
  type        = string
}