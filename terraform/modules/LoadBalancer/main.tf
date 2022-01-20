// Load Balancer
resource "azurerm_lb" "example_lb" {
  name                = var.name
  sku                 = var.sku
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "frontendip"
    subnet_id                     = var.lb_fe_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.0.4"
  }
}

resource "azurerm_lb_backend_address_pool" "example_lb_be_pool" {
  loadbalancer_id = azurerm_lb.example_lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "example_lb_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.example_lb.id
  name                = "api"
  port                = 8080
}

resource "azurerm_lb_rule" "example_rule" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.example_lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.example_lb.frontend_ip_configuration.0.name
  backend_address_pool_ids       = [
    azurerm_lb_backend_address_pool.example_lb_be_pool.id,
  ]
  probe_id                       = azurerm_lb_probe.example_lb_probe.id
  idle_timeout_in_minutes        = 15
  load_distribution              = "Default" //SourceIP or SourceIPProtocol 
  enable_tcp_reset               = false
}

# VM と LB backend pool 関連付け
resource "azurerm_network_interface_backend_address_pool_association" "example_pool_association" {
  for_each                = var.vm_nic_info

  network_interface_id    = each.key
  ip_configuration_name   = each.value.0
  backend_address_pool_id = azurerm_lb_backend_address_pool.example_lb_be_pool.id
}
