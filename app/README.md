# サンプルアプリケーション

## 機能

- 住所検索機能
  - `http://<IPアドレス>/list` にアクセスすると住所検索画面が表示される
  - 住所検索では住所をもとにダミーの個人情報を検索できる

## 環境変数

```
db_user=tsunomur
db_password=Password
db_server=example.database.windows.net
db_database=tsunomuraks
```
※テスト時 .env に記載することで、環境変数を使用できます。

## 実行の手順
1. パッケージのインストール
  - `npm i`
2. 起動
  - `npm start`
3. アクセス
  - `http://<サーバーのIP アドレス>:3000/`