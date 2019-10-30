POSTGRES_USER     ?= root
POSTGRES_PASSWORD ?=

deploy:
	ansible-playbook \
		-e postgres_user="$(POSTGRES_USER)" \
		-e postgres_password="$(POSTGRES_PASSWORD)" \
		-i ../conf/ansible.hosts \
		playbook.yml
