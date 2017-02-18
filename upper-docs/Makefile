HOST_PORT        ?= 9000
CONTAINER_PORT   ?= 9000
CONTAINER_NAME   ?= upper-docs
CONTAINER_IMAGE  ?= upper/docs

deps:
	go get -v menteslibres.net/luminos

run: deps
	if [ ! -f settings.yaml ]; then  \
		cp settings.test.yaml settings.yaml; \
	fi && \
	luminos -c settings.yaml run

docker:
	docker build -t $(CONTAINER_IMAGE) .

docker-run: docker
	(docker stop $(CONTAINER_NAME) || exit 0) && \
	(docker rm $(CONTAINER_NAME) || exit 0) && \
	docker run -d \
		--restart=always \
		-p $(HOST_PORT):$(CONTAINER_PORT) \
		-v $$PWD:/var/docs \
		--name $(CONTAINER_NAME) \
		-t $(CONTAINER_IMAGE)
