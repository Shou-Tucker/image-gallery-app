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

# 環境変数の設定
cp app/.env.example app/.env.local

# Dockerコンテナの起動
docker-compose up -d

# アプリケーションにアクセス
open http://localhost:3000
```

### Terraformによるデプロイ

```bash
cd terraform

# 開発環境へのデプロイ
cp dev.tfvars.example dev.tfvars
# 必要な設定を編集
terraform workspace new dev
terraform init
terraform apply -var-file=dev.tfvars

# 本番環境へのデプロイ
cp prod.tfvars.example prod.tfvars
# 必要な設定を編集
terraform workspace new prod
terraform init
terraform apply -var-file=prod.tfvars
```

## プロジェクト構造

```
.
├── app/                  # Next.jsアプリケーション
│   ├── components/       # UIコンポーネント
│   ├── lib/              # ユーティリティ関数
│   ├── pages/            # ページコンポーネント
│   │   ├── api/          # APIエンドポイント
│   │   └── images/       # 画像関連ページ
│   ├── prisma/           # データベース設定
│   └── styles/           # CSSスタイル
├── db/                   # データベース初期化スクリプト
├── docker-compose.yml    # Docker設定
├── localstack/           # ローカルAWS環境設定
└── terraform/            # インフラ設定
```