# input変数定義：内容は親モジュールに入力可能
# PE 変数
variable "pe_name" {
  type        = string
  description = ""
}

variable "pe_location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "pe_resource_group_name" {
  type        = string
  description = ""
}

variable "pe_subnet_id" {
  type        = string
  description = ""
}

# PL 変数
variable "pl_name" {
  type        = string
  description = ""
}

variable "pl_location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "pl_resource_group_name" {
  type        = string
  description = ""
}

variable "pl_subnet_id" {
  type        = string
  description = ""
}

variable "pl_lb_ids" {
  type        = list(string)  # list 型：["a","b","c"]
  description = ""
}