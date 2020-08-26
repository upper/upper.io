IMAGE_NAME          ?= upper/legacy-docs

GIT_SHORTHASH       ?= $(shell git rev-parse --short HEAD)
IMAGE_TAG           ?= $(GIT_SHORTHASH)

HOST_PORT           ?= 9000
CONTAINER_PORT      ?= 9000

CONTAINER_NAME      ?= upper-docs
DEPLOY_TARGET       ?= staging

docker-build:
	docker build -t $(IMAGE_NAME):$(GIT_SHORTHASH) .

docker-run: docker-build
	(docker rm -f $(CONTAINER_NAME) || exit 0) && \
	docker run -d \
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name $(CONTAINER_NAME) \
		-t $(IMAGE_NAME):$(GIT_SHORTHASH)

docker-push: docker-build
	docker tag $(IMAGE_NAME):$(GIT_SHORTHASH) $(IMAGE_NAME):$(IMAGE_TAG) && \
	docker push $(IMAGE_NAME):$(GIT_SHORTHASH) && \
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		-e image_tag=$(IMAGE_TAG) \
		playbook.yml
