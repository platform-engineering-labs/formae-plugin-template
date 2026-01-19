# Formae Plugin Makefile
#
# Targets:
#   build          - Build the plugin binary
#   test           - Run tests
#   lint           - Run linter
#   clean          - Remove build artifacts
#   install        - Build and install plugin + schemas locally
#   install-schema - Install Pkl schemas for CLI discovery

# Plugin metadata - extracted from formae-plugin.pkl
PLUGIN_NAME := $(shell pkl eval -x 'name' formae-plugin.pkl 2>/dev/null || echo "example")
PLUGIN_VERSION := $(shell pkl eval -x 'version' formae-plugin.pkl 2>/dev/null || echo "0.0.0")

# Build settings
GO := go
GOFLAGS := -trimpath
BINARY := formae-plugin-$(PLUGIN_NAME)

# Installation paths
PLUGIN_DIR := $(HOME)/.pel/formae/plugins
SCHEMA_DIR := $(PLUGIN_DIR)/$(PLUGIN_NAME)/$(PLUGIN_VERSION)/schema/pkl

.PHONY: all build test lint clean install install-schema help

all: build

## build: Build the plugin binary
build:
	$(GO) build $(GOFLAGS) -o bin/$(BINARY) .

## test: Run all tests
test:
	$(GO) test -v ./...

## test-unit: Run unit tests only
test-unit:
	$(GO) test -v -tags=unit ./...

## lint: Run golangci-lint
lint:
	golangci-lint run

## clean: Remove build artifacts
clean:
	rm -rf bin/ dist/

## install-schema: Install Pkl schemas for CLI discovery
install-schema:
	@mkdir -p $(SCHEMA_DIR)
	@cp -r schema/pkl/* $(SCHEMA_DIR)/
	@echo "Installed schemas to $(SCHEMA_DIR)"

## install: Build and install plugin locally (binary + schemas)
install: build install-schema
	@mkdir -p $(PLUGIN_DIR)
	@cp bin/$(BINARY) $(PLUGIN_DIR)/$(PLUGIN_NAME)@$(PLUGIN_VERSION).so
	@echo "Installed $(PLUGIN_NAME)@$(PLUGIN_VERSION) to $(PLUGIN_DIR)"

## help: Show this help message
help:
	@echo "Available targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
