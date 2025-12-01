.PHONY: help up down restart logs status test backup fclean re stable

help: ## Muestra esta ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Inicia los servicios
	docker compose up -d

down: ## Detiene los servicios
	docker compose down

restart: ## Reinicia los servicios
	docker compose restart

logs: ## Muestra logs en tiempo real
	docker compose logs -f

status: ## Estado de los contenedores
	docker compose ps

test: ## Ejecuta tests de verificación
	@echo "🧪 Ejecutando tests..."
	@./tests/test-connection.sh
	@./tests/test-portainer.sh
	@echo "✅ Tests completados."

backup: ## Fuerza backup manual
	@echo "📦 Ejecutando backup manual..."
	docker exec tools_backup sh -c "tar -czf /backup/portainer-data-backup-manual-$$(date +%Y%m%d-%H%M%S).tar.gz -C /source ."
	@echo "✅ Backup completado."

fclean: ## Limpieza completa (elimina volúmenes)
	docker compose down -v
	docker system prune -f

re: fclean up ## Reconstruye todo desde cero

# ------------------------------------------------------------------------------
# SINCRONIZACIÓN CON REPOSITORIO REMOTO
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

stable: ## Push a repositorio remoto
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git add .
	git commit -m "chore: sync $(REPO_NAME)" || true
	git push origin main
	@echo "✅ Despliegue estable completado."
