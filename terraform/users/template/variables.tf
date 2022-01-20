# Demo 環境リソースグループ名
variable "resource_group_name" {
  type        = string
  default     = "demorg01" # リソース グループは他のメンバーと一致しないようにしてください。
  description = ""
}

# aks VNET 名
variable "aks_vnet_name" {
  type        = string
  default     = "demovnet01"
  description = ""
}

# aks クラスタ名
variable "aks_cluster_name" {
  type        = string
  default     = "demoaks01"
  description = ""
}

# mysql server 名
variable "sql_server_name" {
  type        = string
  default     = "demosql01"
  description = ""
}

# acr 名の prefix
variable "acr_name" {
  type        = string
  default     = "demoacr01"
  description = ""
}

# log Analytics 名 prefix
variable "log_name" {
  type        = string
  default     = "tflog01"
  description = ""
}

variable "location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "myipaddress" {
  type = string
}
