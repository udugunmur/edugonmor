.PHONY: up down logs shell backup

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

shell:
	docker exec -it {{cookiecutter.project_slug}}_gitlab_services /bin/bash

backup:
	docker exec -t {{cookiecutter.project_slug}}_gitlab_services gitlab-backup create
