# =====================================================
# 1. Frontend Infrastructure (Web Tier)
# =====================================================

# Public IP for Frontend (Optional if using App Gateway for everything, 
# but kept here per your original design for direct SSH access)
resource "azurerm_public_ip" "frontend_ip" {
  name                = "${local.name_prefix}-fe-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# Frontend NIC and VM
resource "azurerm_network_interface" "frontend_nic" {
  name                = "${local.name_prefix}-fe-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "frontend_vm" {
  name                = "${local.name_prefix}-fe-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.frontend_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202502210"
  }
}

# Backend NIC (This is the one Terraform says is missing!)
resource "azurerm_network_interface" "backend_nic" {
  name                = "${local.name_prefix}-be-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "backend_vm" {
  name                = "${local.name_prefix}-be-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.backend_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${local.name_prefix}-be-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "24.04.202502210"
  }

  custom_data = base64encode(<<EOF
#!/bin/bash
set -e
exec > /var/log/backend-init.log 2>&1

# System packages
apt-get update -y
apt-get install -y git curl

# Node.js 20.x via NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# PM2 process manager
npm install -g pm2

# Clone application repository
git clone ${var.repo_url} /home/azureuser/app

# Write environment configuration
{
  echo "DB_HOST=${azurerm_mysql_flexible_server.mysql.fqdn}"
  echo "DB_NAME=${azurerm_mysql_flexible_database.main_db.name}"
  echo "DB_USER=${var.administrator_login}"
  echo "DB_PASS=${var.db_admin_password}"
  echo "DB_DIALECT=mysql"
  echo "PORT=3001"
  echo "ALLOWED_ORIGINS=http://${azurerm_public_ip.appgw_pip.ip_address}"
} > /home/azureuser/app/backend/.env

# Install production dependencies
cd /home/azureuser/app/backend
npm install --omit=dev

# Set ownership before starting
chown -R azureuser:azureuser /home/azureuser/app

# Start app with PM2 as azureuser
sudo -u azureuser pm2 start /home/azureuser/app/backend/src/server.js --name book-review-backend
sudo -u azureuser pm2 save

# Configure PM2 to restart on system boot
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u azureuser --hp /home/azureuser
systemctl enable pm2-azureuser
EOF
  )

  depends_on = [azurerm_mysql_flexible_server.mysql]
}

