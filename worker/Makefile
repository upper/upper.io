DEPLOY_TARGET     ?= staging

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		playbook.yml

deploy-prod:
	DEPLOY_TARGET=prod $(MAKE) deploy

deploy-unsafebox:
	DEPLOY_TARGET=unsafebox $(MAKE) deploy
