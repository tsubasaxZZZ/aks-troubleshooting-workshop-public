# SSH の 秘密キーを作成 (VM ログイン用)
resource "tls_private_key" "example_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_kubernetes_cluster" "sample_aks" {
  # lifecycle block で、リソースのライフサイクルを定義します。
  # ignore_changes：指定した属性が変更しても、terraform で plan や apply する時に、変更を無視します。
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  # デフォルトのノードプールを作成
  default_node_pool {
      name            = var.default_pool_name  # デフォルトの名前を "agentpool" にしている
      node_count      = var.node_count  # 作成するノードするを指定
      vm_size         = var.vm_size
      vnet_subnet_id  = var.subnet_id  # Azure CNI を利用する場合、指定が必須
  }

  # ログインするための ssh public key を linux node に登録する？
  linux_profile {
      admin_username = "azureuser"

      ssh_key {
          key_data = tls_private_key.example_ssh_private_key.public_key_openssh
      }
  }

  # 「システム割り当てマネージッド ID」の認証方法を指定。 サービス プリンシパルを使う場合、identity{} ではなく、service_principal{} ブロック を使う
  identity {
    type = "SystemAssigned"
  }
  # service_principal {
  #     client_id     = var.client_id
  #     client_secret = var.client_secret
  # }

#   # RBAC を有効にする
#   role_based_access_control {
#     enabled = true
#     /*
#     azure_active_directory {
#       managed = true
#       admin_group_object_ids = [
#         data.azuread_group.aks.id
#       ]
#     }
# */
#   }

  # Azure CNI を利用するための設定、指定なしの場合、kubenet が適用される
  # 注意：Azure CNI を利用する場合、default_node_pool ブロックに、vnet_subnet_id を指定する必要がある
  network_profile {
    network_plugin = "azure"  # Azure CNI を使用。
  }

  # Log Analytics 連携
  # https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/kubernetes/monitoring-log-analytics/main.tf
  addon_profile {
    oms_agent {
      enabled                    = var.log_analytics_audit
      log_analytics_workspace_id = var.log_analytics_id
    }
  }
  
  tags = {
      Environment = "AKS_sample"
  }
}

# プール追加作成
resource "azurerm_kubernetes_cluster_node_pool" "sample_node_pool" {
  for_each = var.add_node_pools ? var.node_pools_info : {}  # ユーザープールの情報を纏めた map タイプの変数でループ処理する。var.add_node_pools 変数でプール作るかの判断をする

  # for loop の中の処理
  # dict のデータはすべて value の中に保存されているので、each.value.<属性> で取得する。※ 親モジュールで output して、tfstate ファイルを確認すれば、内容がわかる
  name                  = each.value.name
  vm_size               = each.value.vm_size
  vnet_subnet_id        = var.subnet_id  # Azure CNI を利用する場合、指定が必須。クラスターと同じ subnet しか使えない？ので、var で直接渡している
  node_count            = each.value.node_count  # enable_auto_scaling 無効の場合、node_count の指定が必要
  
  # mode                  = "${each.mode ? each.mode : "User" }"
  # os_type               = "${each.os_type  ? each.os_type  : "Linux" }"
  # enable_auto_scaling   = true  # 自動スケーリングの設定
  # max_count             = 1  # 0~1000 自動スケーリングの設定
  # min_count             = 1  # 0~1000 自動スケーリングの設定

  kubernetes_cluster_id = azurerm_kubernetes_cluster.sample_aks.id

  tags = {
      Environment = "AKS_sample"
  }
}

## AKS サービスプリンシパル権限設定：サブスクリプションへの権限付与ができるアカウントで実行する必要がある。例：所有者
# AKS のサブネットの権限を付与
resource "azurerm_role_assignment" "sample_aks_role" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.sample_aks.identity[0].principal_id
}

# ACR 権限付与
resource "azurerm_role_assignment" "aks_acr" {
  count = var.acr_role_assignment ? 1 : 0  # count 属性が 0 の場合、作成されないので、作成するかどうかのコントロールで使える

  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.sample_aks.kubelet_identity[0].object_id
}

# AKS oms エージェント 権限設定：Azure Monitor へメトリックデータを送信するための権限付与
# 参考：https://torumakabe.github.io/post/aks-recommended-metrics-alert/
resource "azurerm_role_assignment" "sample_aks_oms_role" {
  count = var.log_analytics_audit ? 1 : 0  # count 属性が 0 の場合、作成されないので、作成するかどうかのコントロールで使える

  scope                = azurerm_kubernetes_cluster.sample_aks.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.sample_aks.addon_profile[0].oms_agent[0].oms_agent_identity[0].object_id  # aks クラスタの addon_profile に対しての設定
}

## Log Analytics Solution
resource "azurerm_log_analytics_solution" "example_log_solution" {
  count = var.log_analytics_audit ? 1 : 0  # count 属性が 0 の場合、作成されないので、作成するかどうかのコントロールで使える

  solution_name         = "ContainerInsights"
  location              = var.log_analytics_location
  resource_group_name   = var.log_analytics_resource_group_name
  workspace_resource_id = var.log_analytics_id
  workspace_name        = var.log_analytics_name

  plan {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
  }
}