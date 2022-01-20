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

variable "subnet_id" {
  type        = string
  description = ""
}

variable "vm_size" {
  type        = string
  description = ""
}

variable "disable_password_auth" {
  type        = bool
  default     = false
  description = "true/false"
}

variable "admin_user" {
  type        = string
  default     = "azureuser"
  description = ""
}

variable "admin_pass" {
  type        = string
  default     = "PaSsW0rd0000"
  description = ""
}

variable "custom_data_script" {}

variable "associate_pip" {
  type        = bool
  default     = false
  description = ""
}
