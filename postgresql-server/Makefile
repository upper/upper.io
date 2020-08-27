POSTGRES_USER     ?= root
POSTGRES_PASSWORD ?=

DEPLOY_TARGET     ?= demo

deploy:
	ansible-playbook \
		-e host="$(DEPLOY_TARGET)" \
		-e postgres_user="$(POSTGRES_USER)" \
		-e postgres_password="$(POSTGRES_PASSWORD)" \
		-i ../conf/ansible.hosts \
		playbook.yml

deploy-prod:
	DEPLOY_TARGET=unsafebox $(MAKE) deploy
