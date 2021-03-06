## アーキテクチャ

構築する環境の構成は以下となります。

![](../images/構成図.png)

## Requirements

+ 使用する Azure アカウントは、サブスクリプションの「所有者」権限を持っていること
+ Azure ポータルへアクセスできること

## 環境デプロイ手順

1. [Azure ポータルサイト](https://portal.azure.com/)へログインします。
2. 「Cloud Shell」を起動します。
   - 初めて Cloud Shell をご利用の場合、ポータルサイトの指示に従って構築してください。
   ![](../images/CloudShell.png) 
3. 以下のコマンドで、GitHub から構築用ファイルをダウンロードします。
   ```bash
   git clone https://github.com/tsubasaxZZZ/aks-troubleshooting-workshop-public
   cd aks-troubleshooting-workshop-public/terraform
   ```
4. `userslist` に構築するユーザー名リストを更新します。
   - ユーザーごとに改行して記載してください。
   - 作成するリソースグループ名は `ユーザー名-rg` になります。
   - 例：
    ```bash
    user1  # 作成するリソースグループ名：user1-rg
    user2  # 作成するリソースグループ名：user2-rg
    user3  # 作成するリソースグループ名：user2-rg
    ```
5. 以下のコマンドを実行して、環境デプロイ開始します。
   - １ ユーザーあたり 10 分前後かかります。
   ```bash
   bash main.sh
   ```
6. エラーなしで最後まで実行できたことを確認します。

## 構築後状態

- ユーザーごとにリソースグループが作成されます。
- リソースグループ内のリソースは以下のようになっています。
  ![](../images/resources.png) 
- NSG はインターネットからのアクセスをすべてブロックする状態です。

## 構築後の確認ポイント

確認として、任意のユーザーのリソースにて、以下の確認を実施してください。

- 各リソースが展開されていること
- コンテナ レジストリに `sample/demoimage` と `sample/s02image` が展開されていること
- SQL Database にダミーデータが展開されていること
  - データベースに接続する前、Azure SQL Server のファイアウォールにて、接続クライアントの IP を許可する必要がある
  - [データベース接続情報](../README.md)
- 踏み台用の VM にログインできること
  - VM 接続する前、subnet02 の NSG にて、接続クライアントの IP を許可する必要がある
  - [VM 接続情報](../README.md)
- 踏み台用の VM に 以下のツール/ファイルがインストールされていること
  - Docker
  - kubectl コマンド
  - node コマンド
  - /home/azureuser/aks-troubleshooting-workshop-public ディレクトリ
- AKS に namespace が作成されていること
