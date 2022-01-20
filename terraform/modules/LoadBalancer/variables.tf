# input変数定義：内容は親モジュールに入力可能
variable "name" {
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

variable "sku" {
  type        = string
  description = ""
}

variable "lb_fe_subnet_id" {
  type        = string
  description = ""
}

variable "vm_nic_info" {
  type        = map(list(string))
  description = "nic id & nic configrantion name"
}

