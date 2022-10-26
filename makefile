#!/usr/bin/make -f

include makefile.config
-include makefile.config.local

.PHONY: build debug default logs remove run shell start status stop test test-code

default: build

build: Dockerfile
	docker build --force-rm=true --tag=$(registry)$(namespace)/$(image):$(tag) $(buildargs) $(ARGS) .

debug:
	docker run \
		--detach=true \
		--hostname=$(name)-db \
		--name=$(name)-db \
		--tty=true \
		$(dbrunargs) \
		$(registry)$(namespace)/mysql:$(dbtag) \
		$(ARGS)
	docker run \
		--hostname=$(name) \
		--interactive=true \
		--link=$(name)-db:kodi-db \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)$(namespace)/$(image):$(tag) \
		$(ARGS)

logs:
	@docker logs --follow=true $(ARGS) $(name)

remove:
	-@docker rm --force=true --volumes=true $(ARGS) $(name) $(name)-db

run:
	docker run \
		--detach=true \
		--hostname=$(name)-db \
		--name=$(name)-db \
		--tty=true \
		$(dbrunargs) \
		$(registry)$(namespace)/mysql:$(dbtag) \
		$(ARGS)
	docker run \
		--detach=true \
		--hostname=$(name) \
		--link=$(name)-db:kodi-db \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)$(namespace)/$(image):$(tag) \
		$(ARGS)

shell:
	@docker exec --interactive=true --tty=true $(name) /bin/login -f root -p $(ARGS)

start:
	@docker start $(ARGS) $(name)-db $(name)

status:
	@docker ps $(ARGS) --all=true --filter=name=$(name)

stop:
	-@docker stop $(ARGS) $(name) $(name)-db

test: test
	docker create \
		--name=$(name)-test \
		--rm=true \
		--tty=true \
		$(testargs) \
		$(registry)$(namespace)/$(image):$(tag) \
		/test \
		$(ARGS)
	docker cp test $(name)-test:/
	docker start --attach=true $(name)-test

test-code: Dockerfile
	@docker run \
		--interactive=true \
		--rm=true \
		hadolint/hadolint:latest-debian \
		hadolint \
		$(ARGS) \
		- \
		< Dockerfile

