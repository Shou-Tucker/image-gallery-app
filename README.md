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

### ローカル開発環境の起動

```bash
# リポジトリのクローン
git clone https://github.com/Shou-Tucker/image-gallery-app.git
cd image-gallery-app

# 環境変数の設定
cp app/.env.example app/.env.local

# (オプション) クリーンな状態から始める場合
docker-compose down -v

# Dockerコンテナの起動
docker-compose up -d

# ログの確認 (デバッグに有用)
docker-compose logs -f

# アプリケーションのアクセス
open http://localhost:3000
```

### ローカル開発環境の確認

アプリケーションが起動したら、以下の機能をテストできます：

1. 画像のアップロード：「アップロード」ボタンをクリックし、画像を選択、タイトルを入力
2. 画像の一覧表示：ホームページで全ての画像が表示されます
3. 画像の詳細表示：画像カードをクリックして詳細を確認
4. 画像の削除：詳細ページから削除ボタンを使用

### トラブルシューティング

コンテナが正常に起動しない場合は、以下の手順を試してください：

1. **Next.jsアプリケーションのエラー確認**
   ```bash
   docker-compose logs app
   ```

2. **LocalStackのエラー確認**
   ```bash
   docker-compose logs localstack
   ```
   
   LocalStackのエラーが続く場合は、volumeを削除して再試行：
   ```bash
   docker volume rm image-gallery-app_localstack_tmp
   docker-compose up -d
   ```

3. **データベース接続の確認**
   ```bash
   docker-compose exec db psql -U postgres -d image_gallery -c "\dt"
   ```

4. **全てのコンテナとデータをリセット**
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

5. **手動でマイグレーションを実行**
   ```bash
   docker-compose exec app npx prisma migrate deploy
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
│   ├── prisma/           # データベース設定とマイグレーション
│   └── styles/           # CSSスタイル
├── db/                   # データベース初期化スクリプト
├── docker-compose.yml    # Docker設定
├── localstack/           # ローカルAWS環境設定
└── terraform/            # インフラ設定
```
