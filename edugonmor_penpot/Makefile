.PHONY: up down logs restart stable

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

restart: down up

stable:
	@echo "Syncing with remotes..."
	git add .
	git commit -m "Stable release" || true
	git push origin main
