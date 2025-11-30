.PHONY: fclean re test push stable

fclean:
	docker compose -f docker/docker-compose.yml down -v
	docker system prune -f

re: fclean
	docker compose -f docker/docker-compose.yml up -d

test:
	@echo "Running tests..."
	# docker compose -f docker/docker-compose.yml exec ...

push:
	# docker push ...

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

stable:
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git push origin main
	fi
	@echo "✅ Despliegue estable completado."
