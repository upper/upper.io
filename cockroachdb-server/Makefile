COCKROACHDB_USER     ?= demouser
COCKROACHDB_PASSWORD ?= demop4ss
COCKROACHDB_DB       ?= booktown

IMAGE_TAG            ?= v21.2.3

DEPLOY_TARGET        ?= staging

deploy:
	ansible-playbook \
		-e cockroachdb_user="$(COCKROACHDB_USER)" \
		-e cockroachdb_password="$(COCKROACHDB_PASSWORD)" \
		-e cockroachdb_db="$(COCKROACHDB_DB)" \
		-e image_tag="$(IMAGE_TAG)" \
		-e host="$(DEPLOY_TARGET)" \
		-i ../conf/ansible.hosts \
		playbook.yml

deploy-prod:
	DEPLOY_TARGET=unsafebox $(MAKE) deploy
