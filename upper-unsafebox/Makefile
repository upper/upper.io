IMAGE_NAME ?= upper/unsafebox

docker:
	docker build -t $(IMAGE_NAME) .

docker-run: docker
	(docker stop upper-unsafebox &>/dev/null || exit 0) && \
	(docker rm upper-unsafebox &>/dev/null || exit 0) && \
	docker run \
		-d \
		-p 8080:8080 \
		--privileged \
		--memory 1024Mb \
		--memory-swap 0 \
		--memory-swappiness=0 \
		--name upper-unsafebox \
		--ulimit nofile=256:512 \
		--ulimit nproc=128 \
		-t upper/unsafebox

deploy:
	sup prod deploy
