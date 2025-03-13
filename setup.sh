#!/bin/bash
# Linux/macOS用セットアップスクリプト

# カラー表示用の関数
function echo_color() {
  local color=$1
  local message=$2
  
  case $color in
    "green") echo -e "\033[0;32m$message\033[0m" ;;
    "red") echo -e "\033[0;31m$message\033[0m" ;;
    "yellow") echo -e "\033[0;33m$message\033[0m" ;;
    "cyan") echo -e "\033[0;36m$message\033[0m" ;;
    *) echo "$message" ;;
  esac
}

# OSタイプの確認
function detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

OS_TYPE=$(detect_os)
echo_color "cyan" "OS検出: $OS_TYPE"

# Dockerが起動しているか確認
echo_color "cyan" "Dockerの確認中..."
if ! docker info > /dev/null 2>&1; then
  echo_color "red" "エラー: Dockerが起動していないか、インストールされていません"
  
  if [[ "$OS_TYPE" == "macos" ]]; then
    echo_color "yellow" "Docker Desktopを起動してください"
  elif [[ "$OS_TYPE" == "linux" ]]; then
    echo_color "yellow" "以下のコマンドでDockerを起動してみてください："
    echo_color "yellow" "sudo systemctl start docker"
  fi
  
  exit 1
fi

echo_color "green" "Dockerは正常に起動しています"

# 実行権限の設定
echo_color "cyan" "スクリプトに実行権限を付与しています..."
chmod +x app/startup.sh
chmod +x localstack/init-s3.sh

# Dockerリソースのクリーンアップ
echo_color "cyan" "Dockerリソースをクリーンアップしています..."
docker-compose down -v
docker volume prune -f
docker system prune -af

# 環境変数ファイルの準備
echo_color "cyan" "環境変数ファイルを準備しています..."
cp -n app/.env.example app/.env.local || true

# コンテナの起動
echo_color "cyan" "Dockerコンテナを起動しています..."
docker-compose up -d

# コンテナの状態確認
echo_color "cyan" "コンテナの状態を確認しています..."
sleep 5
docker-compose ps

# 完了メッセージ
echo_color "green" "セットアップが完了しました！"
echo_color "cyan" "ブラウザで http://localhost:3000 にアクセスしてください"
echo_color "cyan" ""
echo_color "cyan" "問題が発生した場合は以下のコマンドでログを確認できます:"
echo_color "white" "docker-compose logs -f"

# ブラウザを自動で開く
echo_color "cyan" "ブラウザを開きますか？ (y/n): "
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  if [[ "$OS_TYPE" == "macos" ]]; then
    open http://localhost:3000
  elif [[ "$OS_TYPE" == "linux" ]]; then
    xdg-open http://localhost:3000 2>/dev/null || echo_color "yellow" "ブラウザを手動で開いてください: http://localhost:3000"
  fi
fi
