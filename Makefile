POSTGRES_PASSWORD ?=

export POSTGRES_PASSWORD

push:
	for MODULE in unsafebox vanity tour site site.legacy; do \
		$(MAKE) -C $$MODULE docker-push || exit 1; \
	done

deploy:
	$(MAKE) -C postgresql-server deploy && \
	$(MAKE) -C cockroachdb-server deploy && \
	$(MAKE) -C vanity deploy && \
	$(MAKE) -C unsafebox deploy && \
	$(MAKE) -C tour deploy && \
	$(MAKE) -C site deploy && \
	$(MAKE) -C site.legacy deploy
