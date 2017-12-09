.PHONY: mysql-dev mysql-test setup test rel docker-build docker-run \
	checkout-version check-vars target-release

GRINDR_DOCKER_NET?=bridge

setup:
	mix local.hex --force
	mix local.rebar --force

deps: setup
	mix deps.get

target-release:
	cd docker && $(MAKE) profile_service.tar.gz

mysql-test:
	cd docker && $(MAKE) mysql

test: mysql-test
	mix test $$file

rel:
	MIX_ENV=prod mix compile
	MIX_ENV=prod mix release

deploy-latest-tag:
	$(MAKE) deploy commit_ref=$(shell git tag --sort=-v:refname | head -1)

deploy: deps target-release
	cd ansible && $(MAKE) deploy

init-inventory:
	cd ansible && ansible-playbook ./playbooks/initialize.yml \
	-i $(inventory) -u $(ansible_user)

slim-docker:
	docker build -t grindr/profile-service:latest .

run-dockerized: slim-docker
	-@docker rm -f profile-service
	docker run -d --rm --name=profile-service -h profile-service \
	  --net=$(GRINDR_DOCKER_NET) \
	  -e INFO_PORT=9001 \
	  -e PORT=4001 \
	  -e DB_USER=local_user  \
	  -e DB_PASSWORD=local_password \
	  -e DB_HOSTNAME=profiles_mysql \
	  -e DB_DATABASE=grindr \
	  -e IMAGE_HOST="http://testcdn" \
	  -p 19001:9001 -p 14001:4001 grindr/profile-service:latest
