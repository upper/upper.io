CONTAINER_PORT ?= 80
HOST_PORT ?= 80
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
	docker run -v $$PWD/conf.d:/etc/nginx/cond.d.t \
		-d \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		--link upper-vanity:upper-vanity \
		--link upper-docs:upper-docs \
		--name $(CONTAINER_NAME) \
		-t $(CONTAINER_IMAGE) && \
	sleep 5 && \
	curl --silent "http://127.0.0.1/db.v2" -H "Host: upper.io" && \
	curl --silent "http://127.0.0.1/db.v1" -H "Host: upper.io" && \
	curl --silent "http://127.0.0.1" -H "Host: upper.io"

deploy-playground:
	sup -f upper-playground/Supfile prod deploy && \
	sup -f upper-unsafebox/Supfile prod deploy

deploy:
	sup prod deploy

deploy-all: deploy-playground deploy
