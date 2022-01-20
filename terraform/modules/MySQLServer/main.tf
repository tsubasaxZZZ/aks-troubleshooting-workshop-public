# リソース 作成
resource "azurerm_mysql_server" "example_mysql" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = var.sku_name  # https://docs.microsoft.com/ja-jp/azure/mysql/tutorial-provision-mysql-server-using-azure-resource-manager-templates?tabs=azure-portal#create-an-azure-database-for-mysql-server-with-vnet-service-endpoint-using-azure-resource-manager-template
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true  # PE や サービスエンド ポイントを使う場合、無効にしたほうがいい
  ssl_enforcement_enabled           = false  # SSL 強制を無効
  # ssl_minimal_tls_version_enforced  = "TLS1_2"
}

# # ファイアウォール ルール
# resource "azurerm_mssql_firewall_rule" "example_mysql_fw_rule" {
#   name             = "All_IP_Allow"
#   server_id        = azurerm_mssql_server.example_mysql.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "255.255.255.255"
# }

resource "azurerm_mysql_database" "example_database" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.example_mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}