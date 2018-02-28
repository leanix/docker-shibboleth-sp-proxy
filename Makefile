.DEFAULT_GOAL := build

BASE_DIR ?= ${CURDIR}

IMAGE_TAG_NAME ?= "arkivum/rdss-archivematica-shib-sp-proxy"
IMAGE_TAG_VERSION ?= "latest"

all: validate clean build

build: build-image

build-image:
	# Build docker image
	@docker build -t "$(IMAGE_TAG_NAME):$(IMAGE_TAG_VERSION)" .

clean:
	# Remove build artefacts
	@rm -Rf "$(BASE_DIR)/build"

validate: validate-yaml validate-ansible

validate-ansible:
	@mkdir -p build/reports/
	@echo "Validating ansible files ... "
	@docker run --rm \
		-v $$(pwd)/ansible:/workspace:ro \
		wpengine/ansible ansible-lint \
			/workspace/configure.yml \
			/workspace/provision.yml \
			| tee build/reports/ansible-lint.txt
	@if [ -s build/reports/ansible-lint.txt ] ; then \
		echo "Validation of ansible files failed." ; \
		return 1 ; \
	else \
		echo "Validated ansible files, all OK." ; \
	fi

validate-yaml:
	@mkdir -p build/reports/
	@echo "Validating yaml files ... "
	@docker run --rm \
		-v $$(pwd)/ansible:/workspace:ro \
		-v $$(pwd)/.yamllintrc:/yamllint/.yamllintrc:ro \
		wpengine/yamllint /workspace | tee build/reports/yamllint.txt
	@if [ -s build/reports/yamllint.txt ] ; then \
		errors=$$(grep error build/reports/yamllint.txt | wc -l) ; \
		notes=$$(grep note build/reports/yamllint.txt | wc -l) ; \
		warnings=$$(grep warning build/reports/yamllint.txt | wc -l) ; \
		echo "Validation of yaml files failed. $${errors} error(s), $${warnings} warning(s), $${notes} note(s)" ; \
		return 1 ; \
	else \
		echo "Validated yaml files, all OK." ; \
	fi

.PHONY: all build build-image clean validate validate-ansible validate-yaml
