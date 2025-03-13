.PHONY: setup start stop reset clean logs purge docker-clean nuclear-option

# 最も安全な方法でセットアップ（完全クリーンアップ後のセットアップ）
safe-setup:
	@echo "完全クリーンアップしてから環境をセットアップしています..."
	@make purge
	@sleep 2
	@make setup

# セットアップと環境起動
setup:
	@echo "環境をセットアップしています..."
	chmod +x app/startup.sh
	chmod +x localstack/init-s3.sh || true
	cp -n app/.env.example app/.env.local || true
	docker-compose down -v || true
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
	chmod +x localstack/init-s3.sh || true
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
	docker volume rm $(docker volume ls -q) || true
	docker system prune -af || true
	rm -rf /tmp/localstack* || true
	@echo "すべてのDockerリソースをクリーンアップしました。"
	@echo "必要であればDockerを再起動し、'make setup'で再度セットアップしてください。"

# 最終手段 - Docker関連のすべてを削除
nuclear-option:
	@echo "警告: これはDockerに関連するすべてのリソースを削除します。本当に実行しますか？ [y/N]"
	@read -p "" response; \
	if [ "$$response" = "y" ] || [ "$$response" = "Y" ]; then \
		docker-compose down -v || true; \
		docker system prune -af --volumes || true; \
		docker volume rm $$(docker volume ls -q) || true; \
		docker rmi $$(docker images -a -q) || true; \
		echo "Docker環境をすべて削除しました。Dockerを再起動してください。"; \
	else \
		echo "操作をキャンセルしました。"; \
	fi

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
