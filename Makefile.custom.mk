# Check https://github.com/fluxcd/flux2/blob/main/.github/runners/prereq.sh if
# you're updating kustomize versions.

MCF_URL := https://github.com/giantswarm/management-cluster-bases/

KUSTOMIZE := ./bin/kustomize
KUSTOMIZE_VERSION ?= v4.5.7

HELM := ./bin/helm

OS ?= $(shell go env GOOS 2>/dev/null || echo linux)
ARCH ?= $(shell go env GOARCH 2>/dev/null || echo amd64)

BUILD_CATALOG_TARGETS := $(addsuffix -catalogs, $(addprefix build-,$(notdir $(wildcard management-clusters/*))))
BUILD_MC_TARGETS := $(addprefix build-,$(notdir $(wildcard management-clusters/*)))

.PHONY: all
all:
	@# noop

.PHONY: build-catalogs-with-defaults
build-catalogs-with-defaults: $(KUSTOMIZE) ## Build Giant Swarm catalogs with default configuration
	@echo "====> $@"
	mkdir -p output
	$(KUSTOMIZE) build --load-restrictor LoadRestrictionsNone ${MCF_URL}/bases/catalogs -o output/catalogs-with-defaults.yaml

.PHONY: $(BUILD_CATALOG_TARGETS)
$(BUILD_CATALOG_TARGETS): $(KUSTOMIZE) ## Build Giant Swarm catalogs for management clusters
	@echo "====> $@"
	mkdir -p output
	$(KUSTOMIZE) build --load-restrictor LoadRestrictionsNone management-clusters/$(subst build-,,$(subst -catalogs,,$@))/catalogs -o output/$(subst build-,,$(subst -catalogs,,$@))-catalogs.yaml

.PHONY: $(BUILD_MC_TARGETS)
$(BUILD_MC_TARGETS): $(KUSTOMIZE) $(HELM)
	@echo "====> $@"
	mkdir -p output
	$(KUSTOMIZE) build --load-restrictor LoadRestrictionsNone --enable-helm --helm-command="$(HELM)" management-clusters/$(subst build-,,$@) -o output/$(subst build-,,$@).yaml
	echo '---' >> output/$(subst build-,,$@).yaml
	$(KUSTOMIZE) build --load-restrictor LoadRestrictionsNone --enable-helm --helm-command="$(HELM)" management-clusters/$(subst build-,,$@)/extras >> output/$(subst build-,,$@).yaml

$(KUSTOMIZE): ## Download kustomize locally if necessary.
	@echo "====> $@"
	mkdir -p $(dir $@)
	curl -sfL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F$(KUSTOMIZE_VERSION)/kustomize_$(KUSTOMIZE_VERSION)_$(OS)_$(ARCH).tar.gz" | tar zxv -C $(dir $@)
	chmod +x $@

$(HELM): ## Download helm locally if necessary.
	@echo "====> $@"
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=$(dir $@) USE_SUDO=false bash
