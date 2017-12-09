.PHONY: deploy

port=4001
info_port=9001
ansible_user=""
db_user=local_user
db_password=local_password
db_database=grindr
db_hostname=localhost

check-vars:
ifndef inventory
	$(error inventory is undefined)
endif
ifndef commit_ref
	$(error commit_ref is undefined)
endif

deploy: check-vars
	ansible-playbook ./playbooks/full_deploy.yml \
	  -i $(inventory) \
	  -e INFO_PORT=$(info_port) \
	  -e PORT=$(port) \
	  -e DB_USER=$(db_user)  \
	  -e DB_PASSWORD=$(db_password) \
	  -e DB_HOSTNAME=$(db_hostname) \
	  -e DB_DATABASE=$(db_database)
