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

variable "paas_resource_id" {
  type        = string
  description = ""
}

# # https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
variable "subresource_names" {
  type        = list(string)
  default     = []
  description = ""
}
