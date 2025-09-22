
NAME := inception

COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE := srcs/.env
WORDPRESS := wordpress
MARIADB := mariadb

# -p: "project name". Docker Compose groups all resources
COMPOSE = docker compose -p $(NAME) -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

DB_VOLUME_DIR = /home/oyuhi/data/db_volume
WP_VOLUME_DIR = /home/oyuhi/data/wp_volume

.PHONY: all up 

all: up

data:
	mkdir -p "$(DB_VOLUME_DIR)" "$(WP_VOLUME_DIR)"

build:
	$(COMPOSE) build 

# -d: Run containers in the background (detached mode)
# --build: rebuild the images before starting container
up : 
	$(COMPOSE) up -d --build


start :
	$(COMPOSE) start

# list containers status 
ps:
	docker ps -a

# service name 
wp:
	$(COMPOSE) exec $(WORDPRESS) bash

db:
	$(COMPOSE) exec $(MARIADB) bash

ls: 
	docker image ls 

logs:
	$(COMPOSE) logs --tail=400

stop :
	$(COMPOSE) stop

# remove also leftover containers from this project not in the current YAML.
down :
	$(COMPOSE) down --remove-orphans

# $$: to pass a literal $ -q: only ID
rmi :
	docker rmi -f $$(docker images -aq)

# remove all unused containers, networks, and images (force, no confirm)
clean: down
	docker system prune -fa

# -r: recursive -f: force
fclean: clean
	-docker volume rm $(docker volume ls -q)
# 	-rm -rf "$(DB_VOLUME_DIR)" "$(WP_VOLUME_DIR)"
# 	-docker run --rm -v $(DB_VOLUME_DIR):/mnt alpine sh -lc 'rm -rf /mnt/* /mnt/.* 2>/dev/null || true'
# 	-docker run --rm -v $(WP_VOLUME_DIR):/mnt alpine sh -lc 'rm -rf /mnt/* /mnt/.* 2>/dev/null || true'
	-mkdir -p "$(DB_VOLUME_DIR)" "$(WP_VOLUME_DIR)"

re: fclean up


.PHONY: all data build up start ps wp db ls logs stop down rmi clean fclean re 









