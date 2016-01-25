deps:
	go get -d -v menteslibres.net/luminos

run:
	luminos -c settings-local.yaml run

docker:
	docker build -t upper/docs .

docker-run: docker
	(docker stop upper-docs &>/dev/null || exit 0) && \
	(docker rm upper-docs &>/dev/null || exit 0) && \
	docker run -d -p 9000:9000 -v $$PWD:/var/docs --name upper-docs -t upper/docs
