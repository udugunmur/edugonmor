.PHONY: fclean re test push stable

NETWORK_NAME=edugonmor_nexus_network

fclean:
	docker compose down -v
	docker system prune -f

re: fclean
	@docker network inspect $(NETWORK_NAME) >/dev/null 2>&1 || docker network create $(NETWORK_NAME)
	docker compose up -d

test:
	@echo "Running tests..."
	# docker compose exec nexus ...

push:
	# docker push ...

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
