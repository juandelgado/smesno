DOCKER := docker
PWD ?= $(shell pwd)

default: run

run:
	@$(DOCKER) run --rm -it \
							-v "$(INPUT):/usr/src/app/input" \
							-w /usr/src/app/src \
							juandelgado/smesno \
							-i ../input \
							-o ../input/lulz.mpg
.PHONY: run

dev-build:
	@$(DOCKER) build -t juandelgado/smesno .
.PHONY: dev-build

dev-sh:
	@$(DOCKER) run --rm -it \
							--entrypoint /bin/bash \
							-v "$(INPUT):/usr/src/app/input" \
							-v $(PWD)/src:/usr/src/app/src \
							-w /usr/src/app/src \
							juandelgado/smesno
.PHONY: dev-sh

dev-lint:
	@$(DOCKER) run --rm \
							--entrypoint rubocop \
							-v $(PWD)/src:/usr/src/app/src \
							-w /usr/src/app/src \
							juandelgado/smesno
.PHONY: dev-lint

dev-lock:
	@$(DOCKER) run --rm \
							-v $(PWD):/usr/src/app \
							-w /usr/src/app \
							ruby:2.5 \
							bundle install
.PHONY: dev-lock
