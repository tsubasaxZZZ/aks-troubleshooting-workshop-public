# input変数定義：内容は親モジュールに入力可能
variable "name" {
  type        = string
  description = ""
}

variable "location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "resource_group_name" {
  type        = string
  description = ""
}

