# Quay builds our images for us, but this might be useful for backporting security updates.

repository := quay.io/qoqodev/elasticsearch-hooks
version := $(shell head -n1 Dockerfile | cut -d: -f2)

default: build push

build:
	docker build -t $(repository):$(version) --build-arg version=$(version) .

push:
	docker push $(repository):$(version)
