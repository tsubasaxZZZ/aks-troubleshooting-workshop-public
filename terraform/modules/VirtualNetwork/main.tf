# 仮想ネットワーク作成
resource "azurerm_virtual_network" "example_vnet" {
  name                = var.name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
      environment = "Terraform Demo"
  }
}

# サブネット作成
resource "azurerm_subnet" "example_subnet" {
  for_each = var.subnet_info  # subnet_info の内容を循環処理する

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = each.value
  enforce_private_link_service_network_policies  = var.disable_private_link_service_network_policies
  enforce_private_link_endpoint_network_policies = var.disable_private_link_endpoint_network_policies  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
}

# サブネットごとに、NSG を作成
resource "azurerm_network_security_group" "example_nsg" {
  for_each = var.subnet_info  # subnet_info の内容を循環処理する

  name                = "${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # security_rule {
  #   name                       = "Allow_IPs"
  #   priority                   = 1000
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = var.allowed_ip
  #   destination_address_prefix = "*"
  # }

  tags = {
    environment = "Terraform Demo"
  }
}

# NSG を subnet に関連付け
# The "each" object can be used only in "module" or "resource" blocks, and only when the "for_each" argument is set.
resource "azurerm_subnet_network_security_group_association" "example_nsg_association" {
  for_each = var.subnet_info  # subnet_info の内容を循環処理する

  subnet_id                 = azurerm_subnet.example_subnet["${each.key}"].id
  network_security_group_id = azurerm_network_security_group.example_nsg["${each.key}"].id  # nsg の属性がなぜか "-nsg" が含まれていない、、、謎。データの詳細は output で確認しよう
}