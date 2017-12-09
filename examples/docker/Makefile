.PHONY: _deploy build-profile-service-image mysql mysql-docker run-profile-service-1 run-profile-service-2 run-profile-services profile_service.tar.gz

GRINDR_DOCKER_NET?=bridge

db_user=local_user
db_password=local_password
db_database=grindr

check-vars:
ifndef commit_ref
	$(error commit_ref is undefined)
endif

profile_service.tar.gz: target-release
	rm -f profile_service.tar.gz
	mv _deploy/profile_service.tar.gz .

target-release: check-vars docker-build
	-docker rm -f amazonlinux-build-box
	docker run --name amazonlinux-build-box \
		-v $$(pwd)/_deploy:/root/_deploy \
		amazonlinux-erl-iex:19.3-14.4.4

run-profiles-service-containers: run-profile-service-container-1 run-profile-service-container-2

docker-build: checkout-version
	docker build -t amazonlinux-erl-iex:19.3-14.4.4 -f Dockerfile .

_deploy:
	rm -rf _deploy && mkdir _deploy

_deploy/profile-service: _deploy
	# We want to be able to test commits that haven't been pushed.
	# So, we check out the local git repo from disk
	repo_dir=$$(cd .. && pwd); \
	git clone --local $$repo_dir _deploy/profile-service

checkout-version: _deploy/profile-service
	cd _deploy/profile-service && \
	git fetch && \
	git checkout $(commit_ref) && \
	make deps

generate-container-keypair:
	rm -rf ../ansible/deployment_test_key*
	ssh-keygen -t rsa -f ../ansible/deployment_test_key -N "" -q

build-profile-service-image: generate-container-keypair
	docker build -t profile-service -f profile-service.dockerfile ..

mysql: mysql-docker
	@echo -n "Waiting for MYSQL: "
	@i=0; while \
	!(mysql -h 127.0.0.1 -P 33306 -uroot -proot $(db_database) \
	   < ../priv/schema.sql 2>error.log); do \
	  sleep 1; echo -n '.'; \
	  if [ $$((i+=1)) -gt 60 ] ; then cat error.log ; exit 1; fi;  \
	done
	@echo "DONE"

mysql-docker:
	@export CURRENT_NET=$$(docker inspect profiles_mysql | jq -r '.[0].NetworkSettings.Networks | keys | .[0]') ;\
	docker ps  | grep profiles_mysql; \
	if [ "$$?" != "0" ] || [ "$$CURRENT_NET" != "$(GRINDR_DOCKER_NET)" ];  then \
	docker rm -f profiles_mysql ; \
	docker run --rm -d --name profiles_mysql -h profiles_mysql \
	  --net=$(GRINDR_DOCKER_NET) \
	  -p 33306:3306 \
	  -e MYSQL_ROOT_PASSWORD=root \
	  -e MYSQL_USER=$(db_user) \
	  -e MYSQL_PASSWORD=$(db_password) \
	  -e MYSQL_DATABASE=$(db_database) \
	  mysql:latest ; \
	else echo "MYSQL running" ; fi

run-profile-service-container-1: build-profile-service-image mysql
	-@docker rm -f profile_service.1
	@docker run -d --name profile_service.1 \
	  --net=$(GRINDR_DOCKER_NET) \
	  --link profiles_mysql:mysql-server \
	  -e DB_HOSTNAME=profiles_mysql \
	  -p 1022:22 -p 14000:4001 -p 19000:9001 profile-service

run-profile-service-container-2: build-profile-service-image mysql
	-@docker rm -f profile_service.2
	@docker run -d --name profile_service.2 \
	  --net=$(GRINDR_DOCKER_NET) \
	  --link profiles_mysql:mysql-server \
	  -e DB_HOSTNAME=profiles_mysql \
	  -p 2022:22 -p 24000:4001 -p 29000:9001 profile-service
