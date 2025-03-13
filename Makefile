.PHONY: setup start stop reset clean logs purge docker-clean

# セットアップと環境起動
setup:
	@echo "環境をセットアップしています..."
	chmod +x app/startup.sh
	cp -n app/.env.example app/.env.local || true
	docker-compose down -v
	docker volume prune -f || true
	docker-compose up -d
	@echo "セットアップが完了しました！http://localhost:3000 にアクセスしてください。"

# アプリケーションの起動
start:
	docker-compose up -d

# アプリケーションの停止
stop:
	docker-compose down

# 環境のリセット (ボリュームも削除)
reset:
	docker-compose down -v
	chmod +x app/startup.sh
	docker volume prune -f || true
	docker-compose up -d

# 完全にクリーンアップ
clean:
	docker-compose down -v
	docker volume prune -f
	docker system prune -f --volumes

# ディスク容量エラー解決のための強制クリーンアップ
purge:
	@echo "Dockerの全リソースを強制的にクリーンアップしています..."
	docker-compose down -v || true
	docker volume prune -f || true
	docker system prune -af || true
	@echo "すべてのDockerリソースをクリーンアップしました。"
	@echo "必要であればDockerを再起動し、'make setup'で再度セットアップしてください。"

# Dockerシステム情報の表示
docker-info:
	@echo "Dockerシステム情報:"
	docker system df
	@echo "\nディスク使用量:"
	df -h

# ログの表示
logs:
	docker-compose logs -f

# 特定サービスのログ表示
app-logs:
	docker-compose logs -f app

db-logs:
	docker-compose logs -f db

localstack-logs:
	docker-compose logs -f localstack
