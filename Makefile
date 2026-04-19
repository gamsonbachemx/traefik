# Traefik Makefile

.PHONY: all build clean test lint fmt generate

# Variables
BINARY := traefik
GO := go
GOFLAGS := -v
LDFLAGS := -ldflags "-s -w"
BUILD_DIR := dist
CMD_DIR := ./cmd/traefik

# Version info
GIT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "dev")
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

LDFLAGS := -ldflags "-s -w \
	-X github.com/traefik/traefik/v3/pkg/version.Version=$(GIT_TAG) \
	-X github.com/traefik/traefik/v3/pkg/version.Codename=traefik \
	-X github.com/traefik/traefik/v3/pkg/version.BuildDate=$(BUILD_DATE)"

all: build

## build: Build the traefik binary
build:
	@echo "Building $(BINARY)..."
	@mkdir -p $(BUILD_DIR)
	$(GO) build $(GOFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY) $(CMD_DIR)

## build-linux: Build for Linux amd64
build-linux:
	@echo "Building $(BINARY) for Linux..."
	@mkdir -p $(BUILD_DIR)
	GOOS=linux GOARCH=amd64 $(GO) build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)_linux_amd64 $(CMD_DIR)

## build-darwin: Build for macOS
build-darwin:
	@echo "Building $(BINARY) for macOS..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=amd64 $(GO) build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)_darwin_amd64 $(CMD_DIR)

## build-darwin-arm: Build for macOS Apple Silicon
build-darwin-arm:
	@echo "Building $(BINARY) for macOS (arm64)..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=arm64 $(GO) build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY)_darwin_arm64 $(CMD_DIR)

## test: Run unit tests
test:
	@echo "Running tests..."
	$(GO) test ./... -race -cover -coverprofile=coverage.out

## test-integration: Run integration tests
test-integration:
	@echo "Running integration tests..."
	$(GO) test ./integration/... -v -timeout 300s

## lint: Run golangci-lint
lint:
	@echo "Running linter..."
	golangci-lint run ./...

## fmt: Format Go source files
fmt:
	@echo "Formatting code..."
	$(GO) fmt ./...
	goimports -w .

## generate: Run go generate
generate:
	@echo "Running go generate..."
	$(GO) generate ./...

## clean: Remove build artifacts
clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@rm -f coverage.out

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t traefik:$(GIT_TAG) .

## deps: Download Go module dependencies
deps:
	$(GO) mod download
	$(GO) mod tidy

## help: Show this help message
help:
	@echo "Usage: make [target]"
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' | sed -e 's/^/ /'
