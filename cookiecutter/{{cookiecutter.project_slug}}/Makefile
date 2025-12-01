.PHONY: fclean re test push stable

fclean:
	docker compose down -v
	docker system prune -f

re: fclean
	docker compose up -d

test:
	@echo "Running tests..."
	# docker compose exec {{cookiecutter.project_slug}}_services mariadb-admin ping -h localhost

push:
	docker push {{cookiecutter.project_slug}}_services:latest

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

.PHONY: stable
stable:
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git push origin main
	@echo "✅ Despliegue estable completado."
