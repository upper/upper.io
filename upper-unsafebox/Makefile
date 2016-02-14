CONTAINER_IMAGE ?= upper/unsafebox
CONTAINER_NAME ?= upper-unsafebox
CONTAINER_PORT ?= 8080
HOST_PORT ?= 8080

docker:
	docker build -t $(CONTAINER_IMAGE) .

docker-run: docker
	(docker stop $(CONTAINER_NAME) &>/dev/null || exit 0) && \
	(docker rm $(CONTAINER_NAME) &>/dev/null || exit 0) && \
	docker run \
		-d \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--privileged \
		--memory 1024Mb \
		--memory-swap 0 \
		--memory-swappiness=0 \
		--name $(CONTAINER_NAME) \
		--ulimit nofile=256:512 \
		--ulimit nproc=128 \
		-t $(CONTAINER_IMAGE)

deploy:
	sup prod deploy
