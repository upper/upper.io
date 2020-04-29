IMAGE_NAME          ?= upper/vanity
IMAGE_TAG           ?= latest
IMAGE_VERSION       ?=

GIT_SHORTHASH       ?= $(shell git rev-parse --short HEAD)

CONTAINER_PORT      ?= 9001
HOST_PORT           ?= 9001

CONTAINER_NAME      ?= upper-vanity

docker-build:
	docker build -t $(IMAGE_NAME):$(GIT_SHORTHASH) .

docker-run: docker-build
	(docker rm $(CONTAINER_NAME) || exit 0) && \
	docker run \
		-d \
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name $(CONTAINER_NAME) \
		-t $(IMAGE_NAME)

docker-push: docker-build
	docker tag $(IMAGE_NAME):$(GIT_SHORTHASH) $(IMAGE_NAME):$(IMAGE_TAG) && \
	docker push $(IMAGE_NAME):$(GIT_SHORTHASH) && \
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e image_tag=$(IMAGE_TAG) \
		playbook.yml
