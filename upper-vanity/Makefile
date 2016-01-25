docker:
	docker build -t upper/vanity .

docker-run: docker
	(docker stop upper-vanity &> /dev/null || exit 0) && \
	(docker rm upper-vanity &> /dev/null || exit 0) && \
	docker run -d -p 9001:9001 --name upper-vanity -t upper/vanity
