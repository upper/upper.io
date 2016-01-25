IMAGE_NAME ?= upper/playground

docker:
	docker build -t $(IMAGE_NAME) .

docker-run: docker
	mkdir -p data && \
	(docker stop upper-playground &>/dev/null || exit 0) && \
	(docker rm upper-playground &>/dev/null || exit 0) && \
	docker run -d -v $$PWD/data:/var/data -p 9002:9002 --name upper-playground -t $(IMAGE_NAME)
