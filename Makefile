deploy:
	for MODULE in worker upper-unsafebox upper-playground upper-tour upper-docs upper-vanity; do \
		$(MAKE) -C $$MODULE docker-push deploy; \
	done
