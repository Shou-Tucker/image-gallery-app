#!/bin/bash

# LocalStackのS3バケット初期化スクリプト
echo "LocalStackの初期化を開始します..."

# 必要な環境変数を設定
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
LOCALSTACK_HOST=localstack
ENDPOINT_URL=http://${LOCALSTACK_HOST}:4566

# LocalStackが完全に起動するまで待機
echo "LocalStackが起動するまで待機しています..."
max_retries=30
retry_count=0
until $(curl --silent --fail ${ENDPOINT_URL}/health &>/dev/null); do
  retry_count=$((retry_count+1))
  if [ $retry_count -eq $max_retries ]; then
    echo "LocalStackの起動待機がタイムアウトしました"
    exit 1
  fi
  echo "LocalStackの起動を待機中... ($retry_count/$max_retries)"
  sleep 2
done

echo "LocalStackが起動しました。S3バケットを作成します..."

# S3バケットの作成
aws --endpoint-url=${ENDPOINT_URL} s3 mb s3://image-gallery-local

# バケットのACLを公開読み取り可能に設定
echo "バケットACLを設定しています..."
aws --endpoint-url=${ENDPOINT_URL} s3api put-bucket-acl --bucket image-gallery-local --acl public-read

echo "LocalStackの初期化が完了しました。"
