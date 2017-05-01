HOST_PORT ?= 3000
CONTAINER_PORT ?= 3000

CONTAINER_NAME ?= upper-playground
CONTAINER_IMAGE ?= upper/playground

docker:
	docker build -t $(CONTAINER_IMAGE) .

docker-run: docker
	mkdir -p data && \
	(docker stop $(CONTAINER_NAME) || exit 0) && \
	(docker rm $(CONTAINER_NAME) || exit 0) && \
	docker run -d \
		--restart=always \
		-v $$PWD/data:/var/data \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name $(CONTAINER_NAME) \
		-t $(CONTAINER_IMAGE)

deploy:
	sup prod deploy
