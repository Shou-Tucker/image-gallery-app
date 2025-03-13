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

## セットアップ手順

### 1. 事前準備

以下のソフトウェアをインストールしてください：
- [Git](https://git-scm.com/downloads)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac)、または [Docker Engine](https://docs.docker.com/engine/install/) (Linux)

### 2. リポジトリのクローン

```bash
git clone https://github.com/Shou-Tucker/image-gallery-app.git
cd image-gallery-app
```

### 3. 簡単セットアップ (推奨)

**各OS用の強化されたセットアップスクリプトを用意しています**：

#### Windows
PowerShellで以下を実行:
```powershell
# PowerShellを管理者権限で起動することを推奨
.\setup.ps1
```

#### macOS / Linux
ターミナルで以下を実行:
```bash
# 実行権限を付与してから実行
chmod +x setup.sh
./setup.sh
```

#### セットアップスクリプトの特徴

💡 **最新版のスクリプトの改善点：**
- 📊 リアルタイムのステータス表示
- ⚠️ 高度なエラー検出と回復処理
- 🔍 詳細なエラーメッセージとトラブルシューティングガイド
- 🚀 改善されたユーザビリティと視覚フィードバック
- 🛡️ 堅牢なセットアッププロセス

これらのスクリプトは以下の処理を自動的に行います：
- Dockerの起動確認
- 既存のリソースのクリーンアップ
- 環境変数ファイルの設定
- Dockerコンテナの起動
- セットアップ状態の確認
- コンテナ起動状態のモニタリング

### 4. 手動セットアップ

#### Windows

```powershell
# PowerShellを管理者権限で実行

# 既存のDockerリソースをクリーンアップ
docker-compose down -v
docker volume prune -f
docker system prune -af

# 環境変数ファイルをコピー
copy app\.env.example app\.env.local

# Dockerコンテナの起動
docker-compose up -d

# ブラウザでアクセス
start http://localhost:3000
```

#### macOS

```bash
# ターミナルで実行

# 既存のDockerリソースをクリーンアップ
docker-compose down -v
docker volume prune -f
docker system prune -af

# スクリプトに実行権限付与
chmod +x app/startup.sh
chmod +x localstack/init-s3.sh

# 環境変数ファイルをコピー
cp app/.env.example app/.env.local

# Dockerコンテナの起動
docker-compose up -d

# ブラウザでアクセス
open http://localhost:3000
```

#### Linux

```bash
# ターミナルで実行

# 既存のDockerリソースをクリーンアップ
sudo docker-compose down -v
sudo docker volume prune -f
sudo docker system prune -af

# スクリプトに実行権限付与
chmod +x app/startup.sh
chmod +x localstack/init-s3.sh

# 環境変数ファイルをコピー
cp app/.env.example app/.env.local

# Dockerコンテナの起動
sudo docker-compose up -d

# ブラウザでアクセス
xdg-open http://localhost:3000 # または好みのブラウザで localhost:3000 にアクセス
```

### 5. Make コマンドを使ったセットアップ (Linux/macOS)

Linux や macOS では、以下の Make コマンドも使用できます：

```bash
# 完全クリーンアップしてからセットアップ（推奨）
make safe-setup

# または単純なセットアップ
make setup
```

## トラブルシューティング

### 共通の問題

#### コンテナが起動しない場合

自動セットアップスクリプト（`setup.ps1`または`setup.sh`）を実行すると、問題を自動的に検出してトラブルシューティングガイドを表示します。それでも問題が解決しない場合は、以下のコマンドでログを確認してください：

```bash
docker-compose logs -f
```

#### ポート競合の問題

以下のエラーが表示される場合、ポート3000または5432が既に使用されています：
```
Error starting userland proxy: Bind for 0.0.0.0:3000: unexpected error...
```

対処法:
```bash
# 使用中のポートを確認（Windows）
netstat -aon | findstr "3000"
# 使用中のポートを確認（Linux/macOS）
lsof -i :3000
```

既存のプロセスを終了するか、`docker-compose.yml`ファイルでポート設定を変更してください。

### Windows 環境での問題

#### Docker Volume の問題

```powershell
# PowerShellを管理者権限で実行
docker-compose down -v
docker volume prune -f
docker system prune -af

# Docker Desktop を再起動
# スタートメニューからDocker Desktopを再起動

# 再度起動
docker-compose up -d
```

#### WSL2 上での問題

WSL2 を使用している場合、以下のコマンドを試してください：

```bash
# WSL2のターミナルで実行
sudo chmod +x app/startup.sh
sudo chmod +x localstack/init-s3.sh

# Dockerデーモンの再起動
sudo service docker restart

# 再度起動
docker-compose up -d
```

### macOS環境での問題

#### ディスク容量不足

```bash
# Docker Desktopの設定を開き、ディスクイメージサイズを増やす
# または、以下のコマンドでクリーンアップ
docker system prune -af --volumes
rm -rf ~/Library/Containers/com.docker.docker/Data/vms/*

# Docker Desktopを再起動後、再度実行
docker-compose up -d
```

### Linux環境での問題

#### 権限の問題

```bash
# Docker グループにユーザーを追加（sudoなしでDockerを使用可能に）
sudo usermod -aG docker $USER
# 一度ログアウトして再ログイン

# 再度実行
docker-compose up -d
```

#### ディレクトリが空でないエラー

```bash
sudo docker-compose down -v
sudo rm -rf /var/lib/docker/volumes/*
sudo systemctl restart docker
docker-compose up -d
```

## ログの確認

```bash
# すべてのログを表示
docker-compose logs -f

# 特定のサービスのログを確認
docker-compose logs -f app    # アプリケーション
docker-compose logs -f db     # データベース
docker-compose logs -f localstack  # LocalStack
```

## Dockerコンテナの状態確認

```bash
# コンテナの状態を確認
docker-compose ps

# ボリュームの確認
docker volume ls

# Dockerシステムの状態確認
docker system df
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
├── Makefile              # 便利なコマンド集（Linux/macOS用）
├── setup.ps1             # Windows用セットアップスクリプト
├── setup.sh              # macOS/Linux用セットアップスクリプト
└── terraform/            # インフラ設定
```