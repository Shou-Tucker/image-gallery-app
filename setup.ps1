# Windows用セットアップスクリプト (PowerShell)
# 管理者権限で実行することを推奨します

Write-Host "画像ギャラリーアプリケーションのセットアップを開始します..." -ForegroundColor Cyan

# Docker が実行中かチェック
try {
    docker info > $null
    Write-Host "Docker が起動しています" -ForegroundColor Green
} catch {
    Write-Host "エラー: Docker が起動していないか、インストールされていません" -ForegroundColor Red
    Write-Host "Docker Desktop をインストールして起動してください: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# クリーンアップ
Write-Host "Docker リソースをクリーンアップしています..." -ForegroundColor Cyan
docker-compose down -v
docker volume prune -f
docker system prune -af

# 環境変数ファイルの準備
Write-Host "環境変数ファイルを準備しています..." -ForegroundColor Cyan
Copy-Item -Path "app\.env.example" -Destination "app\.env.local" -Force

# コンテナの起動
Write-Host "Docker コンテナを起動しています..." -ForegroundColor Cyan
docker-compose up -d

# 状態確認
$running = $true
$retries = 0
$max_retries = 10

while ($running -and $retries -lt $max_retries) {
    $containers = docker-compose ps --services
    $all_healthy = $true
    
    foreach ($container in $containers) {
        $status = docker-compose ps $container | Select-String "Up"
        if (-not $status) {
            Write-Host "コンテナ $container はまだ起動中..." -ForegroundColor Yellow
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
    Write-Host "警告: 一部のコンテナの起動に時間がかかっています。ログを確認してください:" -ForegroundColor Yellow
    Write-Host "docker-compose logs" -ForegroundColor Yellow
} else {
    Write-Host "すべてのコンテナが起動しました！" -ForegroundColor Green
}

# アクセス方法の案内
Write-Host "`nセットアップが完了しました！" -ForegroundColor Green
Write-Host "ブラウザで http://localhost:3000 にアクセスしてください" -ForegroundColor Cyan
Write-Host "`n問題が発生した場合は以下のコマンドでログを確認できます:" -ForegroundColor Cyan
Write-Host "docker-compose logs -f" -ForegroundColor White

# ブラウザを自動で開く
Write-Host "`nブラウザを開きますか？ (y/n): " -ForegroundColor Cyan -NoNewline
$response = Read-Host
if ($response -eq "y" -or $response -eq "Y") {
    Start-Process "http://localhost:3000"
}