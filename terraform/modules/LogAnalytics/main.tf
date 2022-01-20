# resource "random_id" "log_analytics_workspace_name_suffix" {
#     byte_length = 8
# }

# リソースグループ名に依存するランダム文字列を生成する(リソースグループ名が変わらない限り、この文字列も変わらない)
# Container Registry は世界中に一意である必要があるため、ランダムな値を使用する
resource "random_id" "Random_Suffix_String" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8  # 長さ定義
}


resource "azurerm_log_analytics_workspace" "example_log" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.name}suf${random_id.Random_Suffix_String.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}

