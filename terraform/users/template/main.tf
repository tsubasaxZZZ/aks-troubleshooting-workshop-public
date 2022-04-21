# チュートリアル：https://docs.microsoft.com/ja-jp/azure/developer/terraform/get-started-cloud-shell

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# リソースグループを作成する
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# 仮想ネットワーク作成
module "vnet" {
  source = "../../modules/VirtualNetwork"

  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  name                = var.aks_vnet_name
  vnet_address_space  = ["10.10.0.0/16"]
  subnet_info = {
    "akssubnet01" = ["10.10.100.0/24"],
    "subnet01"    = ["10.10.1.0/24"],
    "subnet02"    = ["10.10.2.0/24"],
  }

  # allowed_ip                = var.myipaddress

  enforce_private_link_endpoint_network_policies = true
}

# Log Analytics Workspace 作成
module "log_analytics" {
  source = "../../modules/LogAnalytics"

  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  name                = var.log_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# AKS クラスター作成
module "aks" {
  source = "../../modules/KubernetesService"

  cluster_name        = var.aks_cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  dns_prefix          = "tfaksdnsprefix01" # ホストされた Kubernetes API サーバー FQDN で使用する DNS 名プレフィックス。The name can contain only letters, numbers, and hyphens

  # default node pool の設定
  subnet_id  = module.vnet.network_output["akssubnet01"].id
  vm_size    = "Standard_B2ms"
  node_count = 1

  # # node pool の追加
  # add_node_pools         = true  # ノードプールを追加するかどうか
  # # ノードプールの情報
  # node_pools_info        = {
  #   "pool01" : {
  #     "name"               = "userpool01",
  #     "vm_size"            = "Standard_B2ms",
  #     "node_count"         = 1,
  #   },
  # }

  ## aks 権限設定
  # ACR の pull 権限設定
  acr_role_assignment   = true
  container_registry_id = module.acr.return_acr_info.id

  ## Log Analytics 設定
  log_analytics_audit               = true
  log_analytics_location            = module.log_analytics.return_log_info.location
  log_analytics_resource_group_name = module.log_analytics.return_log_info.resource_group_name
  log_analytics_id                  = module.log_analytics.return_log_info.id
  log_analytics_name                = module.log_analytics.return_log_info.name
}

# SQL Server 作成：DB として使用
module "sqlserver" {
  source = "../../modules/SQLServer"

  # Server 情報
  server_name         = var.sql_server_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location

  # database 情報
  requested_service_objective_name = "Basic" # GP_Gen5_2 ,確認コマンド：az sql db list-editions -l japaneast -o table
  database_name                    = "demo_db"
}


# ACR 作成
module "acr" {
  source = "../../modules/ContainerRegistry"

  name                = var.acr_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
}

### Azure DB for sql の PE を作成：AKS はデフォルトでは、インターネットへのアクセスはできません（CNI）
### Private Endpoint ###
module "pe" {
  source = "../../modules/PrivateLink_PaaS"

  # pe 設定
  pe_name                = "${var.sql_server_name}_pe01"
  pe_resource_group_name = azurerm_resource_group.example.name
  pe_location            = var.location
  pe_subnet_id           = module.vnet.network_output["subnet01"].id
  paas_resource_id       = module.sqlserver.return_sql_info.id # PE 利用するには sku が汎用以上必要

  # Private link resource の種類：https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
  subresource_names = [
    "sqlServer",
  ]
}

# 作業用 VM の作成：ubuntu:azure-cli,kubectl,nodejs,docker
module "vm01" {
  source = "../../modules/VirtualMachine"

  name                  = "demovm01"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  subnet_id             = module.vnet.network_output["subnet02"].id
  vm_size               = "Standard_B2ms"
  disable_password_auth = false
  associate_pip         = true # pip 付けるかどうかを判断するために作った変数

  # ※注意：改行コードが "/r/n" (CRLF：Windows) の場合、正常動作しないので、"/n" (Linux：LF) にしてください
  custom_data_script = <<EOF
#!/bin/bash
sudo apt-get update && sudo apt-get install -y \
    ca-certificates \
    curl \
    apt-transport-https \
    lsb-release \
    gnupg \
    gnupg2 \
    gnupg-agent \
    npm \
    software-properties-common
# azure cli
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install azure-cli
# kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
# Docker 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker "azureuser"
# Nodejs
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
# Download training files
sudo -u azureuser git clone https://github.com/tsubasaxZZZ/aks-troubleshooting-workshop-public /home/azureuser/aks-troubleshooting-workshop-public
EOF

  depends_on = [
    module.vnet,
  ]
}

################################
# SQL Database へデータをインポート #
################################

# クライアントのIPの穴あけをする
resource "azurerm_sql_firewall_rule" "example" {
  name                = "ImportSQLClient"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = module.sqlserver.return_sql_info.name
  start_ip_address    = var.myipaddress
  end_ip_address      = var.myipaddress
}

# SQL のインポート
# 何回でも実行できるようにするには triggers を "always_run" = "${timestamp()}" とする。
resource "null_resource" "import_sql" {
  triggers = {
    "uniqstr" = azurerm_resource_group.example.name
  }
  provisioner "local-exec" {
    working_dir = path.root
    command     = "bash ../../../app/importsql.sh ${module.sqlserver.return_sql_info.fully_qualified_domain_name} ${module.sqlserver.return_sql_info.administrator_login} ${module.sqlserver.return_sql_info.administrator_login_password} ${module.sqlserver.return_sql_database_info.name}"
  }
  depends_on = [
    azurerm_sql_firewall_rule.example
  ]
}

################################
# SQL アクセスするためのプライベート DNS #
################################

resource "azurerm_private_dns_zone" "example" {
  name                = "database.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_a_record" "example" {
  name                = "${module.sqlserver.return_sql_info.name}"
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = ["${module.pe.return_pe_info.custom_dns_configs[0].ip_addresses[0]}"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "Link_to_${module.vnet.network_info.name}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = module.vnet.network_info.id
}