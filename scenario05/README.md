# シナリオ 5 : Web アプリケーションへアクセスしたときにエラーが発生する

## 演習の概要とねらい
アプリケーションを展開する際、さまざまなエラーに直面することがあります。すでに解決されている問題もあればまだ解決されていない問題もあります。特に広く使われているオープンソースのプロダクトでは、GitHub でソースが公開され、エラー、機能追加、バグ修正などが議論されていることがあります。それらの議論を確認することで、発生している問題の解決や今後のプロダクトの方向性をキャッチアップできる場合があります。GitHub の使い方や作法を覚え、すばやく情報へアクセスできるようにしておきましょう。

この演習では、エラーが発生しているアプリケーションのトラブルシューティングを行います。
GitHub 上で公開されているサンプルのアプリケーションを用いて、エラーの原因の確認と解決していきます。

### 演習の流れ
1. 初めにサンプルのアプリケーションを展開します。<br>
   このアプリケーションは、Node.js で作成されており簡単な住所検索サービスを提供します。アプリケーションは展開されている SQL Database に接続し、検索されたキーワードをもとに SQL Database へクエリを発行します。
   AKS へアプリケーションを展開するためのマニュフェストを用意していますのでご活用ください。
2. 続いて展開したアプリケーションにアクセスします。<br>
   前述のマニュフェストを用いると、アプリケーションの展開(Pod の作成)と同時に Service を作成するため、インターネット上からアプリケーションへアクセス可能です。
3. アプリケーションのエラーを確認します。<br>
   [現象の確認](#現象の確認)の手順に従って、エラーを確認します。多くのアプリケーションやフレームワークは、英語でエラーが表示されるためその時点で解決を諦めてしまう人がいます。出力されているエラーに解決策がそのまま書いてあるケースもあるので、まずはメッセージを正しく理解することが重要です。

## 準備
1. `./scenario05/deployment.yaml` を開く
2. `db_server` の value を展開されている SQL Database のサーバー名に変更する  
    例: `demosql01.database.windows.net`
3. `kubectl apply -f ./scenario05/deployment.yaml` を実行する
4. `kubectl get svc -n scenario05` を実行して Service の IP アドレスを確認する<br>
   `EXTERNAL-IP` が Service の IP アドレスです。IP アドレスが取得できるまで `<pending>` と表示されます。
   ```shell
   # kubectl get svc
   NAME        TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
   sampleapp   LoadBalancer   10.0.127.167   20.48.84.99   80:30475/TCP   2m22s
   ```

## 現象の確認

1. `http://<Service の IP アドレス>/list` にアクセスする
2. [検索] ボタンを押す
3. `Failed to connect to example.database.windows.net:1433 in 10ms` エラーが発生する

## ゴール
エラーを解消する。

## ヒント

<details>
    <summary>コンテナのログを確認する</summary>

Pod のログを確認してみましょう。
```
kubectl logs <Pod 名> -f ※-f を付けることでリアルタイムにログを見ることができます。
例)
kubectl logs sampleapp-fd4d45b84-2nxb5 -f -n scenario05
```
</details>

<details>
    <summary>GitHub の Issues を確認する</summary>

- アプリケーションの GitHub のリポジトリにアクセスし、Issues を確認してみましょう。
  - GitHub のリポジトリ: https://github.com/tsubasaxZZZ/aks-troubleshooting-workshop-public

</details>

<details>
    <summary>ソースコードを確認する</summary>

- アプリケーションのソースコードを確認してみましょう。
  - ソースコード: https://github.com/tsubasaxZZZ/aks-troubleshooting-workshop-public/blob/main/app/sql.js
  - 登録されている Issue の内容に該当する記述が無いか確認してみましょう。

</details>

<details>
    <summary>環境変数の設定</summary>

- `./scenario05/deployment.yaml` を開き、新しい環境変数を追加してみましょう。
- 変更したマニュフェストファイルは、`kubectl apply -f ./scenario05/deployment.yaml` で適用します。

</details>

## トラブルシューティング
**※ここから下は自分で答えを見つけてから確認しましょう。**

<details>
    <summary>解決方法を見る</summary>
    
### 1. deployment.yaml の修正

`./scenario05/deployment.yaml` に以下の環境変数を追加します。

```
- name: db_connectTimeoutMsec
  value: "1000"
```

### 2. deployment.yaml の適用

修正した `./scenario05/deployment.yaml` を適用します。

```
# kubectl apply -f scenario05/deployment.yaml
deployment.apps/sampleapp configured
service/sampleapp unchanged
```

### トラブルシューティングのポイント
現象を確認するとエラーから、`10ms` 以内にデータベースへ接続できないことが分かります。

Pod のログを確認すると同じエラーが出力されています。

```javascript
ConnectionError: Failed to connect to example.database.windows.net:1433 in 10ms
    at Connection.connectTimeout (/app/node_modules/tedious/lib/connection.js:1232:26)
    at Timeout._onTimeout (/app/node_modules/tedious/lib/connection.js:1177:12)
    at listOnTimeout (internal/timers.js:557:17)
    at processTimers (internal/timers.js:500:7) {
  code: 'ETIMEOUT',
  isTransient: undefined
}
```

GitHub のリポジトリの Issues を確認してみると、同じような Issue(質問) が見つかります。その返信を見ると、アプリケーションは環境変数(`db_connectTimeoutMsec`)でデータベースへの接続までのタイムアウトを設定できるということが分かります。

https://github.com/tsubasaxZZZ/aks-troubleshooting-workshop-public/issues/1

そこでソースコードを見てみると、データベースへ接続すると思われる `sql.js` 内で以下のようなコードが見つかります。
```javascript
const executeSQL = (sql, params) => new Promise((resolve, reject) => {

    let results = [];

    const connection = new Connection({
        server: process.env["db_server"],
        authentication: {
            type: 'default',
            options: {
                userName: process.env["db_user"],
                password: process.env["db_password"],
            }
        },
        options: {
            database: process.env["db_database"],
            encrypt: true,
            connectTimeout: Number(process.env["db_connectTimeoutMsec"] || 10) <------- ここ
        }
    });
```

ここまでの調査で修正箇所が分かりました。幸い、ハードコーディングではなく環境変数で設定されている部分であるため、Kubernetes のマニフェスト内で環境変数を設定することで値を変更できます。

### Tips. Kubernetes で動くアプリケーションに値を渡す方法
アプリケーションでは設定・パラメータ・シークレットなど動作する環境に応じて変更しなければならない値があります。

一般的にそのような値をアプリケーションにハードコーディングする(固定の定数として実装する)ことは、柔軟性に欠けてしまうため変数として外部のソースを参照します。アプリケーションから外部のソースを参照する方法としては、ファイルに記述する、データベースに情報を格納しておく、環境変数に設定する等の方法があります。特に環境変数を用いることで OS やミドルウェアに依存しない値へのアクセス方法が提供できる、設定手順が統一化できる、複数のプログラムで値が共有できる等のメリットがあります。

Kubernetes は、アプリケーションに値を渡す方法としてさまざまな方法を提供しています。環境変数を用いることもできますし、ファイルとしてマウントもできます。詳細については、以下のドキュメントを参照してください。

https://kubernetes.io/docs/tasks/inject-data-application/

注意点として、環境変数の値は暗号化がされていません。たとえば Pod にアクセスできる権限を持っていると誰でも参照できてしまいます。特に AKS を Azure Monitor と連携している場合、デフォルトでは環境変数の値を取得するため、意図せずシークレットにアクセスできてしまうことにならないように注意が必要です。Key Vault を使用する等シークレットの扱いは十分に検討が必要です。

</details>

## 環境のクリーンアップ

次のシナリオで使うので、環境は残したままにしておきます。