CONTAINER_PORT ?= 80
HOST_PORT ?= 80

CONTAINER_PORT_HTTPS ?= 443
HOST_PORT_HTTPS ?= 443

CONTAINER_NAME ?= upper.io
CONTAINER_IMAGE ?= upper/upper.io

docker:
	docker build -t $(CONTAINER_IMAGE) .

machines:
	$(MAKE) docker docker-run -C upper-vanity && \
	$(MAKE) docker docker-run -C upper-docs

docker-run: docker machines
	(docker stop $(CONTAINER_NAME) || exit 0) && \
	(docker rm $(CONTAINER_NAME) || exit 0) && \
	docker run \
		-d \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		-p $(HOST_PORT_HTTPS):$(CONTAINER_PORT_HTTPS) \
		--link upper-vanity:upper-vanity \
		--link upper-docs:upper-docs \
		--name $(CONTAINER_NAME) \
		-v $$PWD/conf.d:/etc/nginx/cond.d.t \
		-v /etc/private:/etc/private \
		-t $(CONTAINER_IMAGE) && \
	sleep 5 && \
	curl --silent "http://127.0.0.1/db.v2" -H "Host: beta.upper.io" && \
	curl --silent "http://127.0.0.1/db.v1" -H "Host: beta.upper.io" && \
	curl --silent "http://127.0.0.1" -H "Host: beta.upper.io"

deploy-playground:
	sup -f upper-playground/Supfile prod deploy && \
	sup -f upper-unsafebox/Supfile prod deploy

deploy:
	sup prod deploy

deploy-all: deploy-playground deploy
