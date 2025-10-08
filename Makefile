.PHONY: help dev build package sideload test clean

# Configuration
ROKU_IP ?= 192.168.1.100
ROKU_USER ?= rokudev
ROKU_PASS ?= $(shell cat .roku_password 2>/dev/null || echo "rokudev")
APP_NAME = DarttsIPTV
BUILD_DIR = build
DIST_DIR = dist

help:
	@echo "Dartt's IPTV - Roku Channel Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make dev        - Build and sideload to Roku (quick dev loop)"
	@echo "  make build      - Build channel package"
	@echo "  make package    - Create distributable ZIP"
	@echo "  make sideload   - Sideload to Roku device"
	@echo "  make test       - Run unit tests"
	@echo "  make clean      - Clean build artifacts"
	@echo ""
	@echo "Environment variables:"
	@echo "  ROKU_IP         - Roku device IP (default: 192.168.1.100)"
	@echo "  ROKU_USER       - Dev installer username (default: rokudev)"
	@echo "  ROKU_PASS       - Dev installer password"
	@echo ""
	@echo "Example: make dev ROKU_IP=192.168.1.50"

dev: build sideload
	@echo "✓ Development build deployed to Roku"

build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@rm -rf $(BUILD_DIR)/*
	@cp manifest $(BUILD_DIR)/
	@cp -r source $(BUILD_DIR)/
	@find $(BUILD_DIR) -name ".DS_Store" -delete
	@echo "✓ Build complete"

package: build
	@echo "Creating distributable package..."
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR) && zip -r ../$(DIST_DIR)/$(APP_NAME).zip . -x "*.DS_Store"
	@echo "✓ Package created: $(DIST_DIR)/$(APP_NAME).zip"

sideload: build
	@echo "Sideloading to Roku at $(ROKU_IP)..."
	@bash scripts/sideload.sh $(ROKU_IP) $(ROKU_USER) $(ROKU_PASS) $(BUILD_DIR)

test:
	@echo "Running unit tests..."
	@bash tests/run_tests.sh

integration-test:
	@echo "Running integration tests..."
	@ROKU_IP=$(ROKU_IP) bash tests/integration/test_deep_linking.sh

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)
	@rm -rf logs
	@echo "✓ Clean complete"

lint:
	@echo "Linting BrightScript files..."
	@echo "⚠️  Manual lint required - install bslint or use VS Code extension"
	@find source -name "*.brs" -o -name "*.xml" | head -5

validate:
	@echo "Validating manifest..."
	@bash scripts/validate_manifest.sh

.DEFAULT_GOAL := help
