DEPLOY_TARGET         ?= demo
PLAYGROUND_IMAGE_TAG  ?= v0.10.0-rc1

GIT_SHORTHASH         ?= $(shell git rev-parse --short HEAD)

HOST_PORT             ?= 3000
CONTAINER_PORT        ?= 3000

CONTAINER_NAME        ?= upper-playground

docker-run:
	mkdir -p data && \
	(docker rm -f $(CONTAINER_NAME) || exit 0) && \
	docker run -d \
		--restart=always \
		-v $$PWD/data:/var/data \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--name $(CONTAINER_NAME) \
		-t xiam/go-playground:$(PLAYGROUND_IMAGE_TAG)

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		-e playground_image_tag=$(IMAGE_TAG) \
		playbook.yml
