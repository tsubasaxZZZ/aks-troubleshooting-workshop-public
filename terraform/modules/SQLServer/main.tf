# リソースグループ名に依存するランダム文字列を生成する(リソースグループ名が変わらない限り、この文字列も変わらない)
# sql server は世界中に一意である必要があるため、ランダムな値を使用する
resource "random_id" "Random_Suffix_String" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8 # 長さ定義
}


# リソース 作成
resource "azurerm_sql_server" "example_sql_server" {
  name                         = "${var.server_name}-${random_id.Random_Suffix_String.hex}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = "demo"
  }
}

resource "azurerm_sql_database" "example_database" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.example_sql_server.name
  collation           = "Japanese_CI_AS"

  requested_service_objective_name = var.requested_service_objective_name

  tags = {
    environment = "demo"
  }
}
