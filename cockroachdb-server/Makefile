COCKROACHDB_USER     ?= root
COCKROACHDB_DB       ?= demo

deploy:
	ansible-playbook \
		-e cockroachdb_user="$(COCKROACHDB_USER)" \
		-e cockroachdb_db="$(COCKROACHDB_DB)" \
		-i ../conf/ansible.hosts \
		playbook.yml
