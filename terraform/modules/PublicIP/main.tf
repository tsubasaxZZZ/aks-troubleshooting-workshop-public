# パブリック IP 作成
resource "azurerm_public_ip" "example_pip" {

  name                    = "${var.name}-pip"
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  sku                     = "Standard"  # Standard の場合、Static が必須

  tags = {
    environment = "Terraform Demo"
  }
}
