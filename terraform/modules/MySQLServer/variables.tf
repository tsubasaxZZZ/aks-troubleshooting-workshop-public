variable "server_name" {
  type        = string
  description = ""
}

variable "resource_group_name" {
  type        = string
  description = ""
}

variable "location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "sku_name" {
  type        = string
  default     = "B_Gen5_1"
  description = "PE を利用するには、汎用 sku 以上は必要です。最安は GP_Gen5_2"
}

variable "database_name" {
  type        = string
  default     = "demo_db"
  description = ""
}