include ./srcs/.env

COMPOSE_FILE = srcs/docker-compose.yml
HOST_DATA_DIR?=/home/hirwatan/data

all: build up

build:
	mkdir -p $(HOST_DATA_DIR)/mariadb
	mkdir -p $(HOST_DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

# 構築 起動
up:
	docker compose -f $(COMPOSE_FILE) up -d

# 停止　ボリューム化してないものは消える
down:
	docker compose -f $(COMPOSE_FILE) down

# 一時停止
stop:
	docker compose -f $(COMPOSE_FILE) stop

# 再開
start:
	docker compose -f $(COMPOSE_FILE) start

# 再起動
restart: down up

# 各コンテナの
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

#
clean: down
	docker system prune -a -f
	docker volume prune -f

fclean: clean
	sudo rm -rf $(HOST_DATA_DIR)
	docker rmi -f $$(docker images -qa) 2>/dev/null || true
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	docker network rm $$(docker network ls -q) 2>/dev/null || true

re: fclean all

# 状態
status:
	docker compose -f $(COMPOSE_FILE) ps

# イメージ
images:
	docker images

# shellに入る
exec-mariadb:
	docker exec -it mariadb bash

exec-wordpress:
	docker exec -it wordpress bash

exec-nginx:
	docker exec -it nginx bash

.PHONY: all build up down stop start restart logs clean fclean re status exec-mariadb exec-wordpress exec-nginx