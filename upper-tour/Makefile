IMAGE_TAG         ?= latest
DEPLOY_TARGET     ?= staging

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		-e image_tag="$(IMAGE_TAG)" \
		playbook.yml
