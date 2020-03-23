# Copyright 2016 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# set default shell
SHELL = bash -e -o pipefail

# Variables
VERSION                    ?= $(shell cat ./VERSION)

DOCKER_LABEL_VCS_DIRTY     = false
ifneq ($(shell git ls-files --others --modified --exclude-standard 2>/dev/null | wc -l | sed -e 's/ //g'),0)
    DOCKER_LABEL_VCS_DIRTY = true
endif

## Docker related
DOCKER_EXTRA_ARGS          ?=
DOCKER_REGISTRY            ?=
DOCKER_REPOSITORY          ?=
DOCKER_TAG                 ?= $(VERSION)$(shell [[ $(DOCKER_LABEL_VCS_DIRTY) == "true" ]] && echo "-dirty" || true)
IMAGENAME                  := $(DOCKER_REGISTRY)$(DOCKER_REPOSITORY)voltha-ofagent-py:$(DOCKER_TAG)

## Docker labels. Only set ref and commit date if committed
DOCKER_LABEL_VCS_URL       ?= $(shell git remote get-url $(shell git remote))
DOCKER_LABEL_VCS_REF       = $(shell git rev-parse HEAD)
DOCKER_LABEL_BUILD_DATE    ?= $(shell date -u "+%Y-%m-%dT%H:%M:%SZ")
DOCKER_LABEL_COMMIT_DATE   = $(shell git show -s --format=%cd --date=iso-strict HEAD)

DOCKER_BUILD_ARGS ?= \
	$(DOCKER_EXTRA_ARGS) \
	--build-arg org_label_schema_version="$(VERSION)" \
	--build-arg org_label_schema_vcs_url="$(DOCKER_LABEL_VCS_URL)" \
	--build-arg org_label_schema_vcs_ref="$(DOCKER_LABEL_VCS_REF)" \
	--build-arg org_label_schema_build_date="$(DOCKER_LABEL_BUILD_DATE)" \
	--build-arg org_opencord_vcs_commit_date="$(DOCKER_LABEL_COMMIT_DATE)" \
	--build-arg org_opencord_vcs_dirty="$(DOCKER_LABEL_VCS_DIRTY)"

DOCKER_BUILD_ARGS_LOCAL ?= $(DOCKER_BUILD_ARGS) \
	--build-arg LOCAL_PYVOLTHA=$(LOCAL_PYVOLTHA) \
	--build-arg LOCAL_PROTOS=$(LOCAL_PROTOS)

.PHONY: rw_core ro_core local-protos local-pyvoltha

# This should to be the first and default target in this Makefile
help:
	@echo "Usage: make [<target>]"
	@echo "where available targets are:"
	@echo
	@echo "docker-build         : Build the docker images."
	@echo "docker-push          : Push the docker images to an external repository"
	@echo "venv                 : Build local Python virtualenv"
	@echo "clean                : Remove files created by the build and tests"
	@echo "distclean            : Remove venv directory"
	@echo "lint                 : Shorthand for lint-style & lint-sanity"
	@echo "test                 : Generate reports for all go tests"
	@echo

local-protos:
	mkdir -p local_imports
ifdef LOCAL_PROTOS
	mkdir -p local_imports/voltha-protos/dist
	cp ${LOCAL_PROTOS}/dist/*.tar.gz local_imports/voltha-protos/dist/
endif

local-pyvoltha:
	mkdir -p local_imports
ifdef LOCAL_PYVOLTHA
	mkdir -p local_imports/pyvoltha/dist
	cp ${LOCAL_PYVOLTHA}/dist/*.tar.gz local_imports/pyvoltha/dist/
endif

## lint and unit tests

VENVDIR := venv-ofagent

$(VENVDIR):
	virtualenv-2.7 $@;\
	source ./$@/bin/activate ; set -u ;\
	pip install -r requirements.txt

lint: lint-dockerfile

test:
	tox

## Docker targets
lint-dockerfile:
	@echo "Running Dockerfile lint check ..."
	@hadolint $$(find . -name "Dockerfile")
	@echo "Dockerfile lint check OK"

docker-build: local-protos local-pyvoltha
	docker build $(DOCKER_BUILD_ARGS) \
    -t $(IMAGENAME) \
    --build-arg LOCAL_PYVOLTHA=$(LOCAL_PYVOLTHA) \
    --build-arg LOCAL_PROTOS=$(LOCAL_PROTOS) \
    --build-arg org_label_schema_version="$(VERSION)" \
    --build-arg org_label_schema_vcs_url="$(DOCKER_LABEL_VCS_URL)" \
    --build-arg org_label_schema_vcs_ref="$(DOCKER_LABEL_VCS_REF)" \
    --build-arg org_label_schema_build_date="$(DOCKER_LABEL_BUILD_DATE)" \
    --build-arg org_opencord_vcs_commit_date="$(DOCKER_LABEL_COMMIT_DATE)" \
    -f Dockerfile .

docker-push:
	docker push ${IMAGENAME}

# cleanup
clean:
	rm -rf python/local_imports

clean-all: clean
	rm -rf $(VENVDIR)
