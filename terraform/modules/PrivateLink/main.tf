# Private Link Service 作成
resource "azurerm_private_link_service" "example_pl" {
  name                = var.pl_name
  location            = var.pl_location
  resource_group_name = var.pl_resource_group_name

  nat_ip_configuration {
    name                       = "primary"
    private_ip_address         = "10.10.0.50"
    private_ip_address_version = "IPv4"
    subnet_id                  = var.pl_subnet_id
    primary                    = true
  }

  load_balancer_frontend_ip_configuration_ids = var.pl_lb_ids
}

# private endpoint 作成
resource "azurerm_private_endpoint" "example_pe" {
  name                  = var.pe_name
  location              = var.pe_location
  resource_group_name   = var.pe_resource_group_name
  subnet_id             = var.pe_subnet_id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.example_pl.id
    is_manual_connection           = false
  }
}

