output "appgw_public_ip" {
  description = "Public IP address of the Application Gateway (primary entry point)"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "frontend_public_ip" {
  description = "Direct public IP of the frontend VM (SSH access only)"
  value       = azurerm_public_ip.frontend_ip.ip_address
}

output "backend_private_ip" {
  description = "Private IP of the backend VM within the app subnet"
  value       = azurerm_network_interface.backend_nic.private_ip_address
}

output "mysql_fqdn" {
  description = "Fully qualified domain name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_database_name" {
  description = "Name of the MySQL database created for the application"
  value       = azurerm_mysql_flexible_database.main_db.name
}

output "application_url" {
  description = "URL to access the Book Review application"
  value       = "http://${azurerm_public_ip.appgw_pip.ip_address}"
}
