# リソースグループ名に依存するランダム文字列を生成する(リソースグループ名が変わらない限り、この文字列も変わらない)
# Container Registry は世界中に一意である必要があるため、ランダムな値を使用する
resource "random_id" "Random_Suffix_String" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8  # 長さ定義
}

# Container Registry 作成
resource "azurerm_container_registry" "sample_acr" {
  name                = "${var.name}suf${random_id.Random_Suffix_String.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  admin_enabled       = true  # (Optional) Specifies whether the admin user is enabled. Defaults to false
  sku                 = "Basic"

  tags = {
    environment = "Terraform Demo"
  }
}