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

### 簡単なセットアップ (推奨)

Makefileを使用すると、ワンコマンドでセットアップできます：

```bash
# リポジトリのクローン
git clone https://github.com/Shou-Tucker/image-gallery-app.git
cd image-gallery-app

# セットアップと起動（実行権限設定と環境変数設定も自動で行います）
make setup

# ブラウザでアクセス
open http://localhost:3000
```

その他の便利なコマンド：
```bash
# ログの確認
make logs

# アプリのログのみ表示
make app-logs

# 環境をリセット（ボリュームもクリア）
make reset

# アプリケーションの停止
make stop
```

### 手動セットアップ

```bash
# リポジトリのクローン
git clone https://github.com/Shou-Tucker/image-gallery-app.git
cd image-gallery-app

# 環境変数の設定
cp app/.env.example app/.env.local

# スクリプトに実行権限を付与
chmod +x app/startup.sh

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

1. **起動スクリプトに実行権限があることを確認**
   ```bash
   chmod +x app/startup.sh
   ```

2. **ディスク容量不足エラーに対処**
   ```bash
   # Dockerボリュームを削除してクリーン状態から始める
   docker-compose down -v
   docker volume prune -f
   ```

3. **各サービスのログを確認**
   ```bash
   # アプリケーションのログ
   docker-compose logs app
   
   # データベースのログ
   docker-compose logs db
   
   # LocalStackのログ
   docker-compose logs localstack
   ```

4. **データベース接続の確認**
   ```bash
   docker-compose exec db psql -U postgres -d image_gallery -c "\dt"
   ```

5. **開発環境に合わせた構成の調整**
   * PostgreSQLの設定がディスク使用量を最小化するよう調整済みです
   * 必要に応じて `db/postgresql.conf` の値を調整してください

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
├── Makefile              # 便利なコマンド集
└── terraform/            # インフラ設定
```
