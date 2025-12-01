# cookiecutter Makefile
# https://www.gnu.org/software/make/manual/make.html

IMAGE_NAME := cookiecutter_services
IMAGE_TAG := latest
SERVICE_NAME := cookiecutter_services

.PHONY: build run test clean stable

# ============================================
# 🐳 DOCKER COMMANDS
# ============================================

build:
	docker-compose build

run:
	docker-compose run --rm $(SERVICE_NAME) /bin/bash

# Run tests using pytest (pytest-cookies)
test:
	docker-compose run --rm $(SERVICE_NAME) pytest tests/ -v

# ============================================
# 🚀 RELEASE COMMANDS
# ============================================

stable:
	git push origin main && git push stable main
