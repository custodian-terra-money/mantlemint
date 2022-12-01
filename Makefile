#! /usr/bin/make -f

# Project variables.
PROJECT_NAME = mantlemint
DATE := $(shell date '+%Y-%m-%dT%H:%M:%S')
HEAD = $(shell git rev-parse HEAD)
LD_FLAGS = 
BUILD_FLAGS = -mod=readonly -ldflags='$(LD_FLAGS)'
BUILD_FOLDER = ./dist

## install: Install the binary.
install:
	@echo Installing $(PROJECT_NAME)...
	@go install $(BUILD_FLAGS) ./...
	@mantlemint version

## build: Build the binary.
build:
	@echo Building $(PROJECT_NAME)...
	@-mkdir -p $(BUILD_FOLDER) 2> /dev/null
	@go build $(BUILD_FLAGS) -o $(BUILD_FOLDER) ./...

build-static:
	@echo Building $(PROJECT_NAME)...
	@-mkdir -p $(BUILD_FOLDER) 2> /dev/null
	@docker buildx build --tag terramoney/mantlemint ./
	@docker create --name temp terramoney/mantlemint:latest
	@docker cp temp:/usr/local/bin/mantlemint $(BUILD_FOLDER)/
	@docker rm temp

## mocks: generate mocks
mocks:
	@echo Generating mocks
	@go install github.com/vektra/mockery/v2
	@go generate ./...


## clean: Clean build files. Also runs `go clean` internally.
clean:
	@echo Cleaning build cache...
	@-rm -rf $(BUILD_FOLDER) 2> /dev/null
	@go clean ./...

.PHONY: install build mocks clean

## govet: Run go vet.
govet:
	@echo Running go vet...
	@go vet ./...

## govulncheck: Run govulncheck
govulncheck:
	@echo Running govulncheck...
	@go run golang.org/x/vuln/cmd/govulncheck ./...

## format: Install and run goimports and gofumpt
format:
	@echo Formatting...
	@go run mvdan.cc/gofumpt -w .
	@go run golang.org/x/tools/cmd/goimports -w -local github.com/terra-money/mantlemint .

## lint: Run Golang CI Lint.
lint:
	@echo Running gocilint...
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint run --out-format=tab --issues-exit-code=0

.PHONY: govet format lint

## test-unit: Run the unit tests.
test-unit:
	@echo Running unit tests...
	@go test -race -failfast -v ./...

help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECT_NAME)", or just run 'make' for install"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

.PHONY: help

.DEFAULT_GOAL := install
