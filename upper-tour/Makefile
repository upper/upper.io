HOST_PORT ?= 4000
CONTAINER_PORT ?= 4000

CONTAINER_IMAGE ?= upper/db-tour
CONTAINER_NAME ?= upper-tour

docker:
	docker build --pull -t $(CONTAINER_IMAGE) .

docker-run: docker
	(docker stop $(CONTAINER_NAME) || exit 0) && \
	(docker rm $(CONTAINER_NAME) || exit 0) && \
	docker run -d \
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name $(CONTAINER_NAME) \
		-t $(CONTAINER_IMAGE)

deploy:
	sup prod deploy
