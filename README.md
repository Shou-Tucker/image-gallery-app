# Image Gallery Application

画像アップロード・表示機能を持つWebアプリケーション

## 機能

- 画像のアップロード（タイトルや説明を付けて保存）
- 画像一覧表示
- 画像詳細表示
- モダンなUI

## 技術スタック

- Next.js
- PostgreSQL
- LocalStack（ローカル環境用のAWSエミュレーター）
- Terraform
- Docker

## AWS構成

- Lightsail（Next.jsアプリ、PostgreSQL）
- S3（画像ストレージ）

## 環境

- ローカル開発環境
- 開発環境（クラウド）
- 本番環境（クラウド）

## セットアップ手順

### ローカル開発環境

```bash
# リポジトリのクローン
git clone https://github.com/Shou-Tucker/image-gallery-app.git
cd image-gallery-app

# Dockerコンテナの起動
docker-compose up -d

# Next.jsアプリケーションの起動
cd app
npm install
npm run dev
```

### 環境変数の設定

`.env.example`ファイルをコピーして`.env.local`を作成し、必要な環境変数を設定してください。

### Terraformによるデプロイ

```bash
cd terraform

# 開発環境へのデプロイ
terraform workspace select dev
terraform apply -var-file=dev.tfvars

# 本番環境へのデプロイ
terraform workspace select prod
terraform apply -var-file=prod.tfvars
```