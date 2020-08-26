DEPLOY_TARGET     ?= staging

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		playbook.yml
