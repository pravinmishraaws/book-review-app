# =====================================================
# 6️⃣ Internal Load Balancer (Stable Entry Point for API)
# =====================================================
resource "azurerm_lb" "internal_lb" {
  name                = "${local.name_prefix}-int-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "LoadBalancerFrontend"
    subnet_id                     = azurerm_subnet.app.id
    # BEST PRACTICE: Use Static IP so the App Gateway has a permanent target
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.100" 
  }

  tags = local.common_tags
}

resource "azurerm_lb_backend_address_pool" "app_pool" {
  loadbalancer_id = azurerm_lb.internal_lb.id
  name            = "BackEndAddressPool"
}

# Health Probe: Ensures the Node.js app is actually responding on 3001
resource "azurerm_lb_probe" "app_probe" {
  loadbalancer_id = azurerm_lb.internal_lb.id
  name            = "hp-port-3001"
  port            = 3001
}

# LB Rule: Receives traffic from App Gateway and sends to Backend VM
resource "azurerm_lb_rule" "app_rule" {
  loadbalancer_id                = azurerm_lb.internal_lb.id
  name                           = "LBRule-HTTP-3001"
  protocol                       = "Tcp"
  frontend_port                  = 3001
  backend_port                   = 3001
  frontend_ip_configuration_name = "LoadBalancerFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_pool.id]
  probe_id                       = azurerm_lb_probe.app_probe.id
}

# 🔗 Associate Backend VM NIC with the Internal LB Pool
resource "azurerm_network_interface_backend_address_pool_association" "backend_vm_to_lb" {
  network_interface_id    = azurerm_network_interface.backend_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_pool.id
}

# 🔗 Associate Frontend VM NIC with the Application Gateway Pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "frontend_vm_to_appgw" {
  network_interface_id    = azurerm_network_interface.frontend_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = [for p in azurerm_application_gateway.appgw.backend_address_pool : p.id if p.name == "frontend-vm-pool"][0]
}

# =====================================================
# 7️⃣ Application Gateway (Reverse Proxy & Path Routing)
# =====================================================
resource "azurerm_application_gateway" "appgw" {
  name                = "${local.name_prefix}-appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2" 
    tier     = "Standard_v2"
    capacity = var.appgw_capacity 
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_ip_configuration {
    name                 = "appgw-public-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  # POOL 1: Points to Web VM (Frontend UI)
  backend_address_pool {
    name = "frontend-vm-pool"
  }

  # POOL 2: Points to Internal Load Balancer (Backend API)
  backend_address_pool {
    name         = "api-lb-pool"
    ip_addresses = ["10.0.2.100"] # Matches Internal LB Static IP
  }

  # Settings for Port 80 (Next.js via Nginx)
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80 
    protocol              = "Http"
    request_timeout       = 20
  }

  # Settings for Port 3001 (API Tier)
  backend_http_settings {
    name                  = "api-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 3001
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-public-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # 🛣️ Path-Based Routing Logic
  request_routing_rule {
    name               = "path-routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "http-listener"
    url_path_map_name  = "url-path-map"
    priority           = 100
  }

  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = "frontend-vm-pool"
    default_backend_http_settings_name = "http-settings"

    # Send any URL starting with /api/ to the Internal Load Balancer
    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "api-lb-pool"
      backend_http_settings_name = "api-http-settings"
    }
  }

  tags = local.common_tags
}