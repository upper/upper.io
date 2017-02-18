HOST_PORT ?= 9001
CONTAINER_PORT ?= 9001
CONTAINER_NAME ?= upper-vanity
CONTAINER_IMAGE ?= upper/vanity

docker:
	docker build -t $(CONTAINER_IMAGE) .

docker-run: docker
	(docker stop $(CONTAINER_NAME) || exit 0) && \
	(docker rm $(CONTAINER_NAME) || exit 0) && \
	docker run \
		-d \
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name $(CONTAINER_NAME) \
		-t $(CONTAINER_IMAGE)
