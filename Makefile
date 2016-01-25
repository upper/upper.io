docker:
	docker build -t upper/upper.io .
machines:
	(cd upper-vanity && make docker-run) && \
	(cd upper-unsafebox && make docker-run) && \
	(cd upper-site && make docker-run) && \
	(cd upper-playground && make docker-run)
docker-run: machines
	(docker stop upper.io &>/dev/null || exit 0) && \
	(docker rm upper.io &>/dev/null || exit 0) && \
	docker run -v $$PWD/conf.d:/etc/nginx/cond.d.t \
		-d \
		-p 80:80 \
		--link upper-vanity:upper-vanity \
		--link upper-site:upper-site \
		--name upper.io -t upper/upper.io
