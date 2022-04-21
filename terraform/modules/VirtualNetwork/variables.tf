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

variable "vnet_address_space" {
  type        = list(string)  # list 型変数
  description = ""
}

variable "subnet_info" {
  type        = map(list(string))  # dict 型：{"key1":"value1","key2":"value2"}。()内に指定している型は value の型。多種類の型を使用したい場合、any 型がある。
  description = ""
}

variable "enforce_private_link_service_network_policies" {
  type        = bool
  default     = false
  description = ""
}

variable "enforce_private_link_endpoint_network_policies" {
  type        = bool
  default     = false
  description = ""
}

variable "allowed_ip" {
  type        = string
  default     = "*"
  description = ""
}