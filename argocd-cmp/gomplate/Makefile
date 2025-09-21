projectname?=gomplate-cmp
K3S_NAME ?= gomplate-cmp

# Get information about git current status
GIT_HEAD_COMMIT ?= $$(git rev-parse --short HEAD)
GIT_REPO        ?= $$(git config --get remote.origin.url)
BUILD_DATE      ?= $(shell date -u +%Y-%m-%dT%H:%M:%S)

# Docker Build
DOCKER_CLI_EXPERIMENTAL ?= enabled
GOARCH          ?= $(shell go env GOARCH)
LOCAL_PLATFORM := linux/$(GOARCH)
TARGET_PLATFORMS ?= $(LOCAL_PLATFORM)

VERSION ?= latest
PLUGIN_IMG ?= kubelize/gomplate-cmp:$(VERSION)

default: help

.PHONY: help
help: ## list makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: docker-build-gomplate-cmp ## build gomplate CMP docker image

.PHONY: clean
clean: ## clean up environment
	@docker rmi $(PLUGIN_IMG) 2>/dev/null || true


.PHONY: docker-build
docker-build: docker-build-gomplate-cmp ## alias for docker-build-gomplate-cmp

.PHONY: docker-build-gomplate-cmp
docker-build-gomplate-cmp: ## build gomplate argocd plugin
	docker build --platform linux/amd64 . -f Dockerfile -t $(PLUGIN_IMG) \
		--build-arg GIT_HEAD_COMMIT=$(GIT_HEAD_COMMIT) \
		--build-arg GIT_REPO=$(GIT_REPO) \
		--build-arg BUILD_DATE=$(BUILD_DATE)

.PHONY: docker-push
docker-push: ## push gomplate CMP docker image
	docker push $(PLUGIN_IMG) 

kind-up:
	@echo "Building kubernetes $${KIND_K8S_VERSION:-v1.25.0}..."
	@kind create cluster --name $(K3S_NAME) --image kindest/node:$${KIND_K8S_VERSION:-v1.25.0} --wait=120s 

kind-load-image: PLUGIN_IMG = ghcr.io/kubelize/gomplate-cmp:local
kind-load-image: docker-build-gomplate-cmp
	@echo "Loading image into cluster..."
	@kind load docker-image ${PLUGIN_IMG} --name $(K3S_NAME)

.PHONY: kind-down
kind-down:
	@echo "Deleting cluser..."
	@kind delete cluster --name $(K3S_NAME)

# Local ArgoCD Development environment
.PHONY: argocd-dev
argocd-dev: kind-up kind-load-image argocd-install
	@echo "ArgoCD is available at http://localhost:8080"
	make argocd-admin

.PHONY: argocd-install
argocd-install:
	@helm repo add argo https://argoproj.github.io/argo-helm
	@helm repo update
	@helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace --values hack/argocd-values.yaml
	@kubectl kustomize hack/ | kubectl apply -f -

argocd-admin:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d