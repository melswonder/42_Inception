NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = ./data

all: build up

build:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

stop:
	docker compose -f $(COMPOSE_FILE) stop

start:
	docker compose -f $(COMPOSE_FILE) start

restart: down up

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	docker system prune -a -f
	docker volume prune -f

fclean: clean
	sudo rm -rf $(DATA_PATH)
	docker rmi -f $$(docker images -qa) 2>/dev/null || true
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	docker network rm $$(docker network ls -q) 2>/dev/null || true

re: fclean all

status:
	docker compose -f $(COMPOSE_FILE) ps

exec-mariadb:
	docker exec -it mariadb bash

exec-wordpress:
	docker exec -it wordpress bash

exec-nginx:
	docker exec -it nginx bash

.PHONY: all build up down stop start restart logs clean fclean re status exec-mariadb exec-wordpress exec-nginx