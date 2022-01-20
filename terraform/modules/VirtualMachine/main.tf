# パブリック IP 作成
resource "azurerm_public_ip" "example_pip" {
  count = var.associate_pip ? 1 : 0  # count 属性が 0 の場合、作成されないので、作成するかどうかのコントロールで使える
  
  name                    = "${var.name}-pip"
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  sku                     = "Standard"  # Standard の場合、Static が必須

  tags = {
    environment = "Terraform Demo"
  }
}

# 仮想マシンの NIC を作成
resource "azurerm_network_interface" "example_nic01" {
    name                        = "${var.name}NIC01"
    location                    = var.location
    resource_group_name         = var.resource_group_name

    # NIC の設定値の定義
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${var.associate_pip == true ? azurerm_public_ip.example_pip[0].id : null }"  # pip と関連付け：分岐処理。上で example_pip に count を使っているので、ここでは [0] が必要になる
        # [count.index] 参考：https://discuss.hashicorp.com/t/how-to-write-the-name-and-ip-of-the-virtual-machine-in-inventory-ini-tmpl-using-terraform-if-it-is-created/19084/2
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# SSH の 秘密キーを作成 (VM ログイン用)
resource "tls_private_key" "example_ssh01" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Linux の仮想マシン作成
resource "azurerm_linux_virtual_machine" "example_Linux_vm" {
    name                  = var.name
    location              = var.location
    resource_group_name   = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.example_nic01.id]
    size                  = var.vm_size

    # OS ディスクのリソース定義
    os_disk {
        name              = "${var.name}_OsDisk"
        caching           = "ReadWrite"
        #Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario
        storage_account_type = "Standard_LRS"
    }

    # イメージ指定
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    # OS 情報を指定
    computer_name  = var.name  # OS の PC 名
    admin_username = var.admin_user  # ローカル管理者名
    admin_password = var.admin_pass  # ローカル管理者パスワード

    # パスワード認証設定
    disable_password_authentication = var.disable_password_auth  # パスワード認証を無効にする (秘密キー認証のみが使えるようになる)
    # 公開キー情報の定義：パスワード認証を false にした場合、必須
    admin_ssh_key {
        username       = var.admin_user  # 認証のユーザーを指定
        public_key     = tls_private_key.example_ssh01.public_key_openssh  # 上記で定義した example_ssh01 の公開キーを使う
    }

    tags = {
        environment = "Terraform Demo"
    }

    # custom_data は Linux に使う場合、cloud-init のスクリプトとして実行される。他のOSでは、ディスクにファイルが作成される。最大 65535 bytes
    custom_data     = base64encode(var.custom_data_script)
}

