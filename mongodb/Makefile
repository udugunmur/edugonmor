.PHONY: fclean re stable

fclean:
	docker compose down -v
	docker system prune -f

re: fclean
	docker compose up -d

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

.PHONY: stable
stable:
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git push origin main
	fi
	@echo "✅ Despliegue estable completado."
