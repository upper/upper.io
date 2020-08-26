IMAGE_NAME        ?= upper/unsafebox

GIT_SHORTHASH     ?= $(shell git rev-parse --short HEAD)
IMAGE_TAG         ?= $(GIT_SHORTHASH)

CONTAINER_PORT    ?= 8080
HOST_PORT         ?= 8080

CONTAINER_NAME    ?= upper-unsafebox

DEPLOY_TARGET     ?= staging

docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

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
		-t $(IMAGE_NAME):latest

docker-push: docker-build
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

deploy: docker-push
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		-e image_tag=$(IMAGE_TAG) \
		playbook.yml
