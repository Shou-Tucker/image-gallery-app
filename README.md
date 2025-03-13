# Image Gallery Application

画像アップロード・表示機能を持つWebアプリケーション

## 重要: 起動時の問題が発生している場合

何度も起動に失敗している場合は、以下の**安全なセットアップ**コマンドを試してください：

```bash
# 最も安全な方法でセットアップ（完全クリーンアップ後）
make safe-setup
```

これでも問題が解決しない場合は、**最終手段**として以下を実行してください：

```bash
# Dockerの環境を完全に初期化（Docker関連のすべてが消去されます！）
make nuclear-option

# Dockerデーモンを再起動
# Linux:
sudo systemctl restart docker
# macOS: Docker Desktopを再起動

# 再セットアップ
make setup
```

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

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/Shou-Tucker/image-gallery-app.git
cd image-gallery-app
```

### 2. 初回セットアップ

```bash
# 以前のDockerリソースをクリーンアップしてから起動（推奨）
make safe-setup

# または単純なセットアップ（問題がなければこちらでOK）
make setup
```

### 3. アプリケーションの確認

ブラウザで http://localhost:3000 にアクセスしてください。

### 4. 便利なコマンド

```bash
# ログの確認
make logs

# アプリのログのみ表示
make app-logs

# データベースのログ確認
make db-logs

# LocalStackのログ確認
make localstack-logs

# 環境をリセット（ボリュームもクリア）
make reset

# アプリケーションの停止
make stop

# Dockerの使用状況確認
make docker-info
```

## トラブルシューティング

### ディレクトリが空でないというエラー

```
initdb: error: directory "/var/lib/postgresql/data/pgdata" exists but is not empty
```

このエラーが表示される場合：

```bash
# すべてのコンテナとボリュームを削除
make purge

# 再セットアップ
make setup
```

### ディスク容量不足エラー

```
No space left on device
```

このエラーが表示される場合：

```bash
# 強力なクリーンアップ
make nuclear-option

# Dockerを再起動
# (システムによって異なる方法)

# 再セットアップ
make setup
```

### LocalStackの初期化エラー

初期化スクリプトに問題がある場合：

```bash
# スクリプトに実行権限を付与
chmod +x localstack/init-s3.sh

# 再起動
make reset
```

## クラウド環境へのデプロイ (Terraform)

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
