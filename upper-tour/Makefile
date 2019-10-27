TAG               ?= latest

deploy:
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e tag=$(TAG) \
		playbook.yml
