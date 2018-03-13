NS ?= docker.io/rammstein4o
VERSION ?= 0.3
UID2USE ?= 1000
GID2USE ?= 1000

IMAGE_NAME ?= base
CONTAINER_NAME ?= base
CONTAINER_INSTANCE ?= default

.PHONY: all build no-cache pull push tag-latest shell start stop rm release

all: build tag-latest

build:
	-docker pull $(NS)/$(IMAGE_NAME):$(VERSION)
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg VERSION=$(VERSION) --build-arg UID=$(UID2USE) --build-arg GID=$(GID2USE) .

no-cache:
	docker build --no-cache -t $(NS)/$(IMAGE_NAME):$(VERSION) --build-arg VERSION=$(VERSION) --build-arg UID=$(UID2USE) --build-arg GID=$(GID2USE) .

pull:
	docker pull $(NS)/$(IMAGE_NAME):$(VERSION)

push:
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

tag-latest:
	docker tag $(NS)/$(IMAGE_NAME):$(VERSION) $(NS)/$(IMAGE_NAME):latest

shell:
	-docker pull $(NS)/$(IMAGE_NAME):$(VERSION)
	docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

start:
	-docker pull $(NS)/$(IMAGE_NAME):$(VERSION)
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

stop:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
	make tag-latest -e VERSION=$(VERSION)
	make push -e VERSION=$(VERSION)
	make push -e VERSION=latest

default: build
