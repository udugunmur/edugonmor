NEXUS_URL=nexus.edugonmor.com/repository/docker-hosted
IMAGE_NAME=edugonmor_ovh_updater
VERSION=latest

.PHONY: fclean re certs-dry certs-run build push deploy stable

fclean:
	docker compose down -v
	docker system prune -f

re: fclean
	docker compose up -d

build:
	docker build -t $(NEXUS_URL)/$(IMAGE_NAME):$(VERSION) -f docker/ovh-updater/Dockerfile .

push: build
	docker push $(NEXUS_URL)/$(IMAGE_NAME):$(VERSION)

deploy: push
	docker compose pull
	docker compose up -d

# Dry run for certificate generation (replace EMAIL and DOMAIN)
certs-dry:
	docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot --dry-run -d $(DOMAIN)

# Real certificate generation
certs-run:
	docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot -d $(DOMAIN)

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
REPO_NAME ?= $(shell basename $(CURDIR))

stable:
	@echo "🚀 Iniciando protocolo de despliegue estable..."
	@echo "📦 Repositorio: $(REPO_NAME)"
	git push origin main
	fi
	@echo "✅ Despliegue estable completado."
