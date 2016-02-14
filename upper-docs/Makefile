HOST_PORT ?= 9000
CONTAINER_PORT ?= 9000
CONTAINER_NAME ?= upper-docs
CONTAINER_IMAGE ?= upper/docs

deps:
	go get -d -v menteslibres.net/luminos

run:
	luminos -c settings-local.yaml run

docker:
	docker build -t $(CONTAINER_IMAGE) .

docker-run: docker
	(docker stop $(CONTAINER_NAME) &>/dev/null || exit 0) && \
	(docker rm $(CONTAINER_NAME) &>/dev/null || exit 0) && \
	docker run -d \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		-v $$PWD:/var/docs \
		--name $(CONTAINER_NAME) \
		-t $(CONTAINER_IMAGE)
