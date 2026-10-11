# ==============================================================================
# Makefile: Local testing & development commands for Playwright Docker Image
# ==============================================================================

IMAGE_NAME ?= github-playwright-image
TAG ?= local-py3.11
PYTHON_VERSION ?= 3.11

.PHONY: help build test run shell clean

help:
	@echo "Available commands:"
	@echo "  make build         - Build shared container image (Python 3.11 + Chromium)"
	@echo "  make test          - Run container smoke tests inside built image"
	@echo "  make run           - Run container and check tool versions"
	@echo "  make shell         - Start interactive bash session in container"
	@echo "  make clean         - Remove local image"

build:
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		-t $(IMAGE_NAME):$(TAG) \
		-f Dockerfile .

test:
	docker run --rm $(IMAGE_NAME):$(TAG) /usr/local/bin/scripts/verify_image.sh

run:
	docker run --rm $(IMAGE_NAME):$(TAG)

shell:
	docker run --rm -it -v $(PWD)/..:/workspace $(IMAGE_NAME):$(TAG) /bin/bash

clean:
	docker rmi $(IMAGE_NAME):$(TAG) || true
