DOCKER := docker
PWD ?= $(shell pwd)

default: run

build:
	@$(DOCKER) build -t gif-o-matic .
.PHONY: build

run: build
	@$(DOCKER) run --rm -it \
							-v "$(INPUT):/usr/src/app/input" \
							-w /usr/src/app/src \
							gif-o-matic \
							-i ../input \
							-o ../input/lulz.mpg
.PHONY: run

lock:
	@$(DOCKER) run --rm \
							-v $(PWD):/usr/src/app \
							-w /usr/src/app \
							ruby:2.5 \
							bundle install
.PHONY: lock
