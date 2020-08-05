COCKROACHDB_USER     ?= demo_user
COCKROACHDB_PASSWORD ?= demo_p4ss
COCKROACHDB_DB       ?= demo
IMAGE_TAG            ?= v20.1.4

deploy:
	ansible-playbook \
		-e image_tag="$(IMAGE_TAG)" \
		-e cockroachdb_user="$(COCKROACHDB_USER)" \
		-e cockroachdb_password="$(COCKROACHDB_PASSWORD)" \
		-e cockroachdb_db="$(COCKROACHDB_DB)" \
		-i ../conf/ansible.hosts \
		playbook.yml
