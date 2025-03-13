# Windows用セットアップスクリプト (PowerShell)
# 管理者権限で実行することを推奨します

# エラーアクションを停止に設定
$ErrorActionPreference = "Stop"

# エラーハンドリング関数
function Handle-Error {
    param(
        [string]$Message
    )
    Write-Host "エラーが発生しました: $Message" -ForegroundColor Red
    Write-Host "セットアップを中断します。" -ForegroundColor Red
    exit 1
}

# クリーンアップ関数
function Cleanup-OnExit {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "警告: セットアッププロセス中に問題が発生しました。" -ForegroundColor Yellow
        Write-Host "詳細はログを確認してください: docker-compose logs" -ForegroundColor Yellow
    }
}

# スクリプト開始
Write-Host "🚀 画像ギャラリーアプリケーションのセットアップを開始します..." -ForegroundColor Cyan

# Docker が実行中かチェック
try {
    Write-Host "🔍 Dockerの確認中..." -ForegroundColor Cyan
    docker info > $null
    Write-Host "✅ Docker が起動しています" -ForegroundColor Green
} 
catch {
    Write-Host "❌ エラー: Docker が起動していないか、インストールされていません" -ForegroundColor Red
    Write-Host "📋 Docker Desktop をインストールして起動してください: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# クリーンアップ
Write-Host "🧹 Docker リソースをクリーンアップしています..." -ForegroundColor Cyan
try {
    docker-compose down -v
    docker volume prune -f
    docker system prune -af
}
catch {
    Write-Host "警告: クリーンアップ中にエラーが発生しましたが、続行します" -ForegroundColor Yellow
}

# 環境変数ファイルの準備
Write-Host "📝 環境変数ファイルを準備しています..." -ForegroundColor Cyan
try {
    if (-not (Test-Path "app\.env.example")) {
        Handle-Error "環境変数のサンプルファイルが見つかりません: app\.env.example"
    }
    Copy-Item -Path "app\.env.example" -Destination "app\.env.local" -Force
}
catch {
    Handle-Error "環境変数ファイルのコピー中にエラーが発生しました: $_"
}

# コンテナの起動
Write-Host "🚀 Docker コンテナを起動しています..." -ForegroundColor Cyan
try {
    docker-compose up -d
}
catch {
    Handle-Error "Dockerコンテナの起動に失敗しました: $_"
}

# 状態確認
Write-Host "🔍 コンテナの状態を確認しています..." -ForegroundColor Cyan
$running = $true
$retries = 0
$max_retries = 10

while ($running -and $retries -lt $max_retries) {
    Write-Host "⏳ コンテナの起動を待機中... ($($retries+1)/$max_retries)" -ForegroundColor Cyan
    
    # 異常終了したコンテナがないかチェック
    $exitedContainers = docker-compose ps | Select-String "Exit"
    if ($exitedContainers) {
        Write-Host "❌ 一部のコンテナが異常終了しています:" -ForegroundColor Red
        docker-compose ps
        Handle-Error "コンテナが正常に起動しませんでした"
    }
    
    $containers = docker-compose ps --services
    $all_healthy = $true
    
    foreach ($container in $containers) {
        $status = docker-compose ps $container | Select-String "Up"
        if (-not $status) {
            Write-Host "⏳ コンテナ $container はまだ起動中..." -ForegroundColor Yellow
            $all_healthy = $false
            break
        }
    }
    
    if ($all_healthy) {
        $running = $false
    } else {
        $retries++
        Start-Sleep -Seconds 5
    }
}

if ($retries -ge $max_retries) {
    Write-Host "❌ 警告: 一部のコンテナの起動に時間がかかっています。ログを確認してください:" -ForegroundColor Yellow
    Write-Host "docker-compose logs" -ForegroundColor Yellow
} else {
    Write-Host "✅ すべてのコンテナが起動しました！" -ForegroundColor Green
}

# アクセス方法の案内
Write-Host "`n✅ セットアップが完了しました！" -ForegroundColor Green
Write-Host "🌐 ブラウザで http://localhost:3000 にアクセスしてください" -ForegroundColor Cyan
Write-Host "`n📋 問題が発生した場合は以下のコマンドでログを確認できます:" -ForegroundColor Cyan
Write-Host "docker-compose logs -f" -ForegroundColor White

# ブラウザを自動で開く
Write-Host "`n🔍 ブラウザを開きますか？ (y/n): " -ForegroundColor Cyan -NoNewline
$response = Read-Host
if ($response -eq "y" -or $response -eq "Y") {
    Start-Process "http://localhost:3000"
}

Write-Host "✨ セットアップ完了 - 画像ギャラリーアプリをお楽しみください！" -ForegroundColor Green