# 作成した IP を親モジュールに返す
output "return_public_ip" {
  value       = azurerm_public_ip.example_pip
  description = "this is a child module, so it return the value"
}

