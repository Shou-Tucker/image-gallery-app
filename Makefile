.PHONY: setup start stop reset clean logs

# セットアップと環境起動
setup:
	@echo "環境をセットアップしています..."
	chmod +x app/startup.sh
	cp -n app/.env.example app/.env.local || true
	docker-compose down -v
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
	docker-compose up -d

# 完全にクリーンアップ
clean:
	docker-compose down -v
	docker system prune -f

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
