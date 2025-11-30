.PHONY: fclean re test push stable

fclean:
	docker compose down -v
	docker system prune -f

re: fclean
	docker compose up -d

test:
	@echo "Running tests..."
	# docker compose exec app ...

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
