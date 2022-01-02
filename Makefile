push:
	for MODULE in upper-unsafebox upper-docs upper-vanity; do \
		$(MAKE) -C $$MODULE docker-push || exit 1; \
	done

deploy:
	$(MAKE) -C postgresql-server deploy
	$(MAKE) -C cockroachdb-server deploy
	$(MAKE) -C upper-docs deploy
