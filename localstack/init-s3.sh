#!/bin/bash

# LocalStackのS3バケット初期化スクリプト
echo "LocalStackの初期化を開始します..."

# 必要な環境変数を設定
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
LOCALSTACK_HOST=localhost
ENDPOINT_URL=http://${LOCALSTACK_HOST}:4566

# S3バケットの作成
echo "S3バケットを作成しています..."
aws --endpoint-url=${ENDPOINT_URL} s3 mb s3://image-gallery-local

# バケットのACLを公開読み取り可能に設定
echo "バケットACLを設定しています..."
aws --endpoint-url=${ENDPOINT_URL} s3api put-bucket-acl --bucket image-gallery-local --acl public-read

echo "LocalStackの初期化が完了しました。"
