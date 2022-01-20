# input変数定義：内容は親モジュールに入力可能

variable "cluster_name" {
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

# ホストされた Kubernetes API サーバー FQDN で使用する DNS 名プレフィックス。クラスターの作成後にコンテナーを管理するときに、これを使用して Kubernetes API に接続します
# Changing this forces a new resource to be created.
variable "dns_prefix" {
  type        = string
  description = ""
}

## default node pool 設定
# Azure CNI 利用を前提として、この値が必須
variable "default_pool_name" {
  type        = string
  default     = "agentpool"
  description = ""
}

variable "subnet_id" {
  type        = string
  description = ""
}

# type 指定しない場合、どんなデータでも格納可能になる
variable "node_count" {
  description = ""
}

variable "vm_size" {
  type        = string
  description = ""
}

## 追加 node pool の情報
# ノードプール追加するかどうか
variable "add_node_pools" {
  type        = bool
  default     = false
}

# the "for_each" argument must be a map, or set of strings, and you have provided a value of type list of object. → だから map() にした。
variable "node_pools_info" {
  type        = map(object({
    name        = string,
    vm_size     = string,
    node_count  = number,
  }))
  default     = {
    "node_pool" : {
      "name"               = "nodepool",
      "vm_size"            = "Standard_B2ms",
      "node_count"         = 1,
    },
  }
  description = "name,vm_size,node_count の key が必須値です"
}

# 指定の ACR の pull 権限を AKS に付与するかどうか
variable "acr_role_assignment" {
  type        = bool
  default     = false
}

# ACR 指定
variable "container_registry_id" {
  type        = string
  description = ""
}

## Log Analytics Solution 有効するか
variable "log_analytics_audit" {
  type        = bool
  default     = false
}

variable "log_analytics_name" {
  type        = string
  description = ""
}

variable "log_analytics_resource_group_name" {
  type        = string
  description = ""
}

variable "log_analytics_location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "log_analytics_id" {
  type        = string
  description = ""
}