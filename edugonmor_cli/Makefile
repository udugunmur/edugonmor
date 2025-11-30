# edugonmor_cli Makefile
# https://www.gnu.org/software/make/manual/make.html
# ⚠️ POLÍTICA DOCKER-FIRST: Todos los comandos se ejecutan dentro de Docker.
#    NO usar pip, pytest, ruff directamente en la máquina host.

# Docker image name
IMAGE_NAME := edugonmor-cli
IMAGE_TAG := latest

.PHONY: build run create help test lint format clean stable

# ============================================
# 🐳 DOCKER COMMANDS (Primary Usage)
# ============================================

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Run CLI interactively (starts a shell with welcome message)
# Mounts local src to site-packages for hot-reloading
run:
	docker run -it --rm \
		-v $(PWD):/workspace \
		-v $(PWD)/src:/usr/local/lib/python3.12/site-packages/src \
		$(IMAGE_NAME):$(IMAGE_TAG)

# Test the wizard by listing templates (triggers SSH connection)
test-wizard:
	docker run -it --rm -v $(PWD):/workspace $(IMAGE_NAME):$(IMAGE_TAG) edugonmor list

# Create a new project: make create NAME=my-api
create:
	@if [ -z "$(NAME)" ]; then echo "❌ Error: NAME is required. Usage: make create NAME=my-project"; exit 1; fi
	docker run -it --rm -v $(PWD):/workspace $(IMAGE_NAME):$(IMAGE_TAG) edugonmor create project $(NAME)

# Show CLI help
help:
	docker run -it --rm $(IMAGE_NAME):$(IMAGE_TAG) edugonmor --help

# ============================================
# 🔧 DEVELOPMENT COMMANDS (Docker-First)
# ============================================

# Run all tests inside Docker container
test:
	docker run --rm -v $(PWD):/workspace -w /workspace $(IMAGE_NAME):$(IMAGE_TAG) \
		pytest tests/ -v --cov=src --cov-report=term-missing

# Lint code inside Docker container
lint:
	docker run --rm -v $(PWD):/workspace -w /workspace $(IMAGE_NAME):$(IMAGE_TAG) \
		ruff check src tests && \
	docker run --rm -v $(PWD):/workspace -w /workspace $(IMAGE_NAME):$(IMAGE_TAG) \
		ruff format --check src tests

# Format code inside Docker container
format:
	docker run --rm -v $(PWD):/workspace -w /workspace $(IMAGE_NAME):$(IMAGE_TAG) \
		ruff format src tests

# Clean build artifacts (local filesystem only)
clean:
	rm -rf build dist *.egg-info .pytest_cache .coverage htmlcov
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

# ============================================
# 🚀 RELEASE COMMANDS
# ============================================

# Push to both remotes (origin and stable)
stable:
	git push origin main && git push stable main
