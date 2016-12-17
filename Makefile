CONTAINER_PORT        ?= 80
HOST_PORT             ?= 80

CONTAINER_PORT_HTTPS  ?= 443
HOST_PORT_HTTPS       ?= 443

CONTAINER_NAME        ?= upper.io
CONTAINER_IMAGE       ?= upper/upper.io

PRIVATE_DIR           ?= /etc/private

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
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		-p $(HOST_PORT_HTTPS):$(CONTAINER_PORT_HTTPS) \
		--link upper-vanity:upper-vanity \
		--link upper-docs:upper-docs \
		--name $(CONTAINER_NAME) \
		-v $$PWD/conf.d:/etc/nginx/conf.d.t \
		-v $$PWD/www:/var/www \
		-v $(PRIVATE_DIR):/etc/private \
		-t $(CONTAINER_IMAGE) && \
	sleep 5 && \
	(curl --verbose -k "https://127.0.0.1/db.v3" -H "Host: upper.io" | grep DOCTYPE || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db.v2" -H "Host: upper.io" | grep DOCTYPE || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db.v1" -H "Host: upper.io" | grep DOCTYPE || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db" -H "Host: upper.io" | grep 302 || exit 1) && \
	(curl --verbose -k "https://127.0.0.1" -H "Host: upper.io" | grep 302 || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db.v3?go-get=1" -H "Host: upper.io" | grep tree/3 || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db.v2?go-get=1" -H "Host: upper.io" | grep tree/2 || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db.v1?go-get=1" -H "Host: upper.io" | grep tree/1 || exit 1) && \
	(curl --verbose -k "https://127.0.0.1/db?go-get=1" -H "Host: upper.io" | grep tree/master || exit 1)


deploy-playground:
	sup -f upper-unsafebox/Supfile prod deploy && \
	sup -f upper-playground/Supfile prod deploy

deploy:
	sup prod deploy

deploy-all: deploy-playground deploy
