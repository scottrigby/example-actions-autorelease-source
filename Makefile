.PHONY: help container-build container-run container-rm generate-gpg-key create-artifacts sign verify test clean

CONTAINER_NAME := gpg-verify
VERSION := v1.0.0-test
DIR := _dist

# Container engine detection for container-* targets
CONTAINER_ENGINE := $(shell command -v podman || command -v docker)
container-%:
	@: "${CONTAINER_ENGINE:?Neither podman nor docker found. Please install one of them}"; \
	echo "Using container engine: $(CONTAINER_ENGINE)"

help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

container-build: ## Build verification container
	@echo 'FROM alpine\nRUN apk add bash curl gnupg coreutils pwgen make\nWORKDIR /verify\nENTRYPOINT ["/bin/bash"]' | \
	$(CONTAINER_ENGINE) build -t $(CONTAINER_NAME) -f -

container-run: container-build ## Run interactive container for testing
	@$(CONTAINER_ENGINE) run --rm -it -v $$(pwd):/verify $(CONTAINER_NAME)

container-rm: ## Remove container image
	-$(CONTAINER_ENGINE) rmi $(CONTAINER_NAME)

generate-gpg-key: ## Generate GPG key pair non-interactively
	@PASSPHRASE=$$(pwgen -s 24 1); \
	echo "$$PASSPHRASE" > passphrase.txt; \
	echo -e "Key-Type: RSA\nKey-Length: 4096\nSubkey-Type: RSA\nSubkey-Length: 4096\nName-Real: Example Release Bot\nName-Email: releases@example.com\nExpire-Date: 0\nPassphrase: $$PASSPHRASE\n%commit\n%echo done" > keybatch; \
	gpg --batch --pinentry-mode loopback --passphrase-file passphrase.txt --full-generate-key keybatch; \
	gpg --batch --pinentry-mode loopback --passphrase-file passphrase.txt --armor --export-secret-keys releases@example.com > private-key.asc; \
	echo "" >> KEYS; \
	echo "# Generated key for releases@example.com" >> KEYS; \
	gpg --armor --export releases@example.com >> KEYS; \
	echo "✓ GPG key generated"

create-artifacts: ## Create mock artifacts for testing
	@mkdir -p $(DIR)
	@for t in linux-amd64 darwin-amd64; do \
		echo "mock binary content for $$t" > $(DIR)/app-$(VERSION)-$$t.tar.gz; \
		cd $(DIR) && sha256sum app-$(VERSION)-$$t.tar.gz > app-$(VERSION)-$$t.tar.gz.sha256sum; \
		cd ..; \
	done

sign: ## Sign artifacts with GPG
	@set -e; \
	: "$${GPG_PRIVATE_KEY:=$$(cat private-key.asc 2>/dev/null)}"; \
	: "${GPG_PRIVATE_KEY:?GPG_PRIVATE_KEY is not set and private-key.asc does not exist}"; \
	: "$${GPG_PASSPHRASE:=$$(cat passphrase.txt 2>/dev/null)}"; \
	: "${GPG_PASSPHRASE:?GPG_PASSPHRASE is not set and passphrase.txt does not exist}"; \
	echo "$$GPG_PRIVATE_KEY" | gpg --batch --import; \
	find $(DIR) -maxdepth 1 -type f -name "app-$(VERSION)-*" ! -name "*.asc" -print | while read f; do \
		gpg --batch --yes --pinentry-mode loopback \
			--passphrase "$$GPG_PASSPHRASE" \
			--detach-sign --armor "$$f"; \
	done; \
	echo "✓ Artifacts signed"

verify: ## Verify signatures and checksums
	@gpg --import KEYS 2>/dev/null || true
	@cd $(DIR) && for f in app-$(VERSION)-*.tar.gz; do \
		gpg --verify $$f.asc $$f; \
		gpg --verify $$f.sha256sum.asc $$f.sha256sum; \
		sha256sum -c $$f.sha256sum; \
	done
	@echo "✓ Verification complete"

test: clean create-artifacts generate-gpg-key sign verify ## Test full workflow: create, sign, and verify
	@echo "✓ Test complete"

clean: ## Clean up test artifacts
	rm -rf $(DIR) keybatch passphrase.txt private-key.asc
