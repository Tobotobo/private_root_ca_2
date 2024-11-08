# private_root_ca_2

## 概要
* プライベートルート証明書の作成をスクリプト化する
* 上記証明書で署名したサーバー証明書の作成をスクリプト化する
* 参照: [private_root_ca](https://github.com/Tobotobo/private_root_ca)

## 詳細

### 環境
```
$ openssl --version
OpenSSL 3.2.1 30 Jan 2024 (Library: OpenSSL 3.2.1 30 Jan 2024)
```
※Windows の場合は Git Bash で実行

### ルート証明書の作成

* 必要に応じて以下を変更  
    root-ca.conf
    ```conf
    [req_dn]
    countryName = "JP"          # 証明書の国コードを指定（ISO 3166-1 の2文字コード）
    organizationName ="Hoge CA" # 証明書の組織名を指定（CAの組織名）
    commonName = "Root CA"      # 証明書の共通名（CN）を指定（ルートCAの識別名）
    ```
* 以下を実行
    ```
    ./generate_root_ca_cert.sh
    ```

### サーバー証明書の作成

* 必要に応じて以下を変更
    server.conf
    ```conf
    [req_distinguished_name]
    C                   = JP # 国コード（ISO 3166-1 の2文字コード、例: JP = 日本）
    O                   = XXXXXXXXX # 組織名（証明書を発行する組織の名前）
    CN                  = example.com # 共通名（証明書の対象となるホスト名やドメイン名を指定）
    # CN                  = XXX.XXX.XXX.XXX # 共通名（証明書の対象となるホスト名やドメイン名を指定）

    [req_ext]
    # subjectAltName の指定は Edge や Chrome で必須
    subjectAltName      = DNS:example.com # サブジェクト代替名（DNS名やIPアドレスを指定して、複数の名前を証明書で使用できるようにする）
    # subjectAltName      = IP:XXX.XXX.XXX.XXX # サブジェクト代替名（DNS名やIPアドレスを指定して、複数の名前を証明書で使用できるようにする）
    ```
* 以下を実行
    ```
    ./generate_server_cert.sh
    ```
