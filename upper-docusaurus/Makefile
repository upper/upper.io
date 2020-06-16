IMAGE_NAME        ?= upper/docusaurus
IMAGE_TAG         ?= latest
IMAGE_VERSION     ?=

GIT_SHORTHASH     ?= $(shell git rev-parse --short HEAD)

CONTAINER_PORT    ?= 80
HOST_PORT         ?= 3080

CONTAINER_NAME    ?= upper-docusaurus
DEPLOY_TARGET     ?= staging

docker-build:
	docker build -t $(IMAGE_NAME):$(GIT_SHORTHASH) .

docker-run: docker-build
	(docker rm -f $(CONTAINER_NAME) || exit 0) && \
	docker run \
		-d \
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
		-e image_tag="$(IMAGE_TAG)" \
		playbook.yml

start:
	cd website && \
		yarn start

install:
	yarn install

clean:
	rm -rf website/build

build: clean
	cd website && \
		yarn run build
