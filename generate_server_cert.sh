#!/usr/bin/env bash

# set -x # 実行したコマンドと引数も出力する
set -e # スクリプト内のコマンドが失敗したとき（終了ステータスが0以外）にスクリプトを直ちに終了する
set -E # '-e'オプションと組み合わせて使用し、サブシェルや関数内でエラーが発生した場合もスクリプトの実行を終了する
set -u # 未定義の変数を参照しようとしたときにエラーメッセージを表示してスクリプトを終了する
set -o pipefail # パイプラインの左辺のコマンドが失敗したときに右辺を実行せずスクリプトを終了する
shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する

# Bash バージョン 4.4 以上の場合のみ実行
if [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 4 ]]; then
    shopt -s inherit_errexit # '-e'オプションをサブシェルや関数内にも適用する
fi

# このスクリプトがあるフォルダへカレントディレクトリを移動
cd "$(dirname "$0")"

wk_dir_path="./server"

key_path="${wk_dir_path}/server.key" # 秘密鍵ファイル
csr_path="${wk_dir_path}/server.csr" # 証明書署名要求ファイル
crt_path="${wk_dir_path}/server.crt" # 証明書ファイル

if [ -d ${wk_dir_path} ]; then
    echo -e "\e[31mERROR: ${wk_dir_path} は既に存在します。\e[m"
    exit 1
fi

mkdir -p "${wk_dir_path}"

# RSAアルゴリズムを使用して秘密鍵を生成する
#   -algorithm: 鍵のアルゴリズムを指定（ここでは RSA）
#   -pkeyopt:   鍵のビット数を指定（ここでは 2048ビット）
#   -out:       生成した秘密鍵を保存するファイルパス
openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:2048 \
    -out "${key_path}"

# 秘密鍵を基に証明書署名要求（CSR）を生成する
#   -config: 設定ファイルを指定（サーバー証明書の詳細設定用）
#   -key:    使用する秘密鍵ファイルのパス
#   -out:    生成したCSRを保存するファイルパス
openssl req -new -config "./server.conf" \
    -key "${key_path}" \
    -out "${csr_path}"

# 証明書署名要求（CSR）に基づきサーバー証明書を発行する
#   -batch:      インタラクティブな入力を省略して自動で実行
#   -config:     設定ファイルを指定（証明書署名に関する設定）
#   -in:         証明書署名要求（CSR）のファイルパス
#   -out:        発行した証明書を保存するファイルパス
#   -extensions: 証明書に追加する拡張設定（server_ext）
openssl ca -batch -config "./sign-server.conf" \
    -in "${csr_path}" \
    -out "${crt_path}" \
    -extensions server_ext

echo "完了"
    