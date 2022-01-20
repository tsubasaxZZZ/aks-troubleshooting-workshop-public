# input変数定義：内容は親モジュールに入力可能
variable "resource_group_name" {
  type        = string
  description = ""
}

variable "location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "name" {
  type        = string
  description = ""
}

variable "sku" {
  type        = string
  description = ""
}

variable "retention_in_days" {
  type        = number
  description = ""
}

