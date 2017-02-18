CONTAINER_IMAGE ?= upper/unsafebox
CONTAINER_NAME ?= upper-unsafebox
CONTAINER_PORT ?= 8080
HOST_PORT ?= 8080

docker:
	docker build -t $(CONTAINER_IMAGE) .

docker-run: docker
	(docker stop $(CONTAINER_NAME) || exit 0) && \
	(docker rm $(CONTAINER_NAME) || exit 0) && \
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
		-t $(CONTAINER_IMAGE) && \
	sleep 5 && \
	curl --data 'version=2&body=package+main%0A%0Aimport+%22fmt%22%0A%0Afunc+main()+%7B%0A%09fmt.Println(%22Hello%2C+playground%22)%0A%7D%0A' "http://127.0.0.1:$(HOST_PORT)/compile?output=json"

deploy:
	sup prod deploy
