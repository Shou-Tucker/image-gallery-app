#!/bin/bash
# Linux/macOS用セットアップスクリプト

# エラーが発生したら中断
set -e

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

# エラーハンドラー
function error_handler() {
  echo_color "red" "エラーが発生しました。セットアップを中断します。"
  echo_color "yellow" "エラーの詳細： $1"
  exit 1
}

# クリーンアップ関数
function cleanup() {
  if [ $? -ne 0 ]; then
    echo_color "yellow" "警告: セットアッププロセス中に問題が発生しました。"
    echo_color "yellow" "詳細はログを確認してください: docker-compose logs"
  fi
}

# 終了時にクリーンアップ関数を呼び出し
trap 'cleanup' EXIT

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
echo_color "cyan" "🔍 OS検出: $OS_TYPE"

# Dockerが起動しているか確認
echo_color "cyan" "🔄 Dockerの確認中..."
if ! docker info > /dev/null 2>&1; then
  echo_color "red" "❌ エラー: Dockerが起動していないか、インストールされていません"
  
  if [[ "$OS_TYPE" == "macos" ]]; then
    echo_color "yellow" "📋 Docker Desktopを起動してください"
  elif [[ "$OS_TYPE" == "linux" ]]; then
    echo_color "yellow" "📋 以下のコマンドでDockerを起動してみてください："
    echo_color "yellow" "   sudo systemctl start docker"
  fi
  
  exit 1
fi

echo_color "green" "✅ Dockerは正常に起動しています"

# 実行権限の設定
echo_color "cyan" "🔐 スクリプトに実行権限を付与しています..."
chmod +x app/startup.sh || error_handler "startup.shに実行権限を付与できませんでした"
chmod +x localstack/init-s3.sh || error_handler "init-s3.shに実行権限を付与できませんでした"

# Dockerリソースのクリーンアップ
echo_color "cyan" "🧹 Dockerリソースをクリーンアップしています..."
docker-compose down -v || echo_color "yellow" "警告: docker-compose down コマンドに問題がありました"
docker volume prune -f || echo_color "yellow" "警告: ボリュームのクリーンアップに問題がありました"
docker system prune -af || echo_color "yellow" "警告: システムプルーンに問題がありました"

# 環境変数ファイルの準備
echo_color "cyan" "📝 環境変数ファイルを準備しています..."
if [ ! -f app/.env.example ]; then
  error_handler "環境変数のサンプルファイルが見つかりません: app/.env.example"
fi

cp -n app/.env.example app/.env.local || echo_color "yellow" "警告: .env.localファイルがすでに存在します。上書きしません。"

# コンテナの起動
echo_color "cyan" "🚀 Dockerコンテナを起動しています..."
docker-compose up -d || error_handler "Dockerコンテナの起動に失敗しました"

# コンテナの状態確認
echo_color "cyan" "🔍 コンテナの状態を確認しています..."
max_retries=10
retries=0
all_healthy=false

while [ $retries -lt $max_retries ] && [ "$all_healthy" != "true" ]; do
  echo_color "cyan" "⏳ コンテナの起動を待機中... ($((retries+1))/$max_retries)"
  sleep 5
  
  if docker-compose ps | grep -q "Exit"; then
    echo_color "red" "❌ 一部のコンテナが異常終了しています："
    docker-compose ps
    error_handler "コンテナが正常に起動しませんでした"
  fi
  
  # すべてのコンテナが起動しているか確認
  if ! docker-compose ps | grep -q "Up" || docker-compose ps | grep -q "starting"; then
    retries=$((retries+1))
  else
    all_healthy=true
  fi
done

if [ "$all_healthy" != "true" ]; then
  echo_color "red" "❌ コンテナの起動タイムアウト"
  echo_color "yellow" "コンテナログを確認してください: docker-compose logs"
  exit 1
fi

# 完了メッセージ
echo_color "green" "✅ セットアップが完了しました！"
echo_color "cyan" "🌐 ブラウザで http://localhost:3000 にアクセスしてください"
echo_color "cyan" ""
echo_color "cyan" "📋 問題が発生した場合は以下のコマンドでログを確認できます:"
echo_color "white" "   docker-compose logs -f"

# ブラウザを自動で開く
echo_color "cyan" "🔍 ブラウザを開きますか？ (y/n): "
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  if [[ "$OS_TYPE" == "macos" ]]; then
    open http://localhost:3000
  elif [[ "$OS_TYPE" == "linux" ]]; then
    xdg-open http://localhost:3000 2>/dev/null || echo_color "yellow" "ブラウザを手動で開いてください: http://localhost:3000"
  fi
fi

echo_color "green" "✨ セットアップ完了 - 画像ギャラリーアプリをお楽しみください！"