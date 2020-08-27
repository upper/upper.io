IMAGE_NAME        ?= upper/tour

GIT_SHORTHASH     ?= $(shell git rev-parse --short HEAD)
IMAGE_TAG         ?= $(GIT_SHORTHASH)

DEPLOY_TARGET     ?= staging

CONTAINER_NAME    ?= upper-tour

.PHONY: vendor

clean:
	rm -rf bin && \
	mkdir -p bin

build: vendor clean fmt
	go build -o ../../bin/tour ./cmd/tour

run:
	go run ./cmd/tour/*.go

vendor:
	cd ./cmd/tour && \
	go mod vendor

fmt:
	for i in $$(find -name \*.go | grep -v vendor); do \
		gofmt -w $$i && \
		goimports -w $$i; \
	done

test:
	for i in $$(find tutorials -name \*.go); do \
		go build -o /tmp/main $$i || exit 1; \
	done

docker-build: fmt
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run: docker-build
	(docker rm -f $(CONTAINER_NAME) || exit 0) && \
	docker run \
		-p 0.0.0.0:4000:4000 \
		--name $(CONTAINER_NAME) \
		-t $(IMAGE_NAME)

docker-push: docker-build
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

deploy: docker-push
	ansible-playbook \
		-i ../conf/ansible.hosts \
		-e host="$(DEPLOY_TARGET)" \
		-e image_tag="$(IMAGE_TAG)" \
		playbook.yml

deploy-prod:
	DEPLOY_TARGET=prod make deploy
