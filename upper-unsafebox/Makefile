IMAGE_NAME        ?= upper/unsafebox
IMAGE_TAG         ?= latest
IMAGE_VERSION     ?=

GIT_SHORTHASH     ?= $(shell git rev-parse --short HEAD)

CONTAINER_PORT    ?= 8080
HOST_PORT         ?= 8080

CONTAINER_NAME    ?= upper-unsafebox

docker-build:
	docker build -t $(IMAGE_NAME):$(GIT_SHORTHASH) .

docker-run: docker-build
	(docker rm -f $(CONTAINER_NAME) || exit 0) && \
	docker run \
		-d \
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--privileged \
		--memory 1024Mb \
		--memory-swap 0 \
		--memory-swappiness=0 \
		--name $(CONTAINER_NAME) \
		--ulimit nofile=256:512 \
		--ulimit nproc=128 \
		-t $(IMAGE_NAME):$(GIT_SHORTHASH)

docker-push: docker-build
	docker tag $(IMAGE_NAME):$(GIT_SHORTHASH) $(IMAGE_NAME):$(IMAGE_TAG) && \
	docker push $(IMAGE_NAME):$(GIT_SHORTHASH) && \
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e image_tag=$(IMAGE_TAG) \
		playbook.yml
