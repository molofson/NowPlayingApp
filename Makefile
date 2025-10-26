## Simple Makefile wrapper for common repeatable steps
# - Uses Swift Package Manager by default
# - Provides optional xcodebuild shortcuts if a .xcodeproj or .xcworkspace exists

SWIFTCMD ?= swift
PACKAGE_PATH ?= .
SCHEME ?= NowPlayingApp
XCODEPROJ := $(wildcard *.xcodeproj)
XCWORKSPACE := $(wildcard *.xcworkspace)

.PHONY: all build run test clean xcode-build xcode-test ci help

all: build

build:
	$(SWIFTCMD) build --package-path $(PACKAGE_PATH)

run:
	$(SWIFTCMD) run --package-path $(PACKAGE_PATH)

test:
	$(SWIFTCMD) test --package-path $(PACKAGE_PATH)


clean:
	$(SWIFTCMD) package clean --package-path $(PACKAGE_PATH) || true
	rm -rf .build build
	rm -rf *.xcuserdata xcuserdata || true
	rm -rf **/.DS_Store || true
	rm -rf .vscode .idea || true
	rm -f Package.resolved || true
	rm -rf .swiftpm || true

ci: clean build test

xcode-build:
	@if [ -n "$(XCWORKSPACE)" ]; then \
		xcodebuild -workspace "$(XCWORKSPACE)" -scheme "$(SCHEME)" -configuration Release build; \
	elif [ -n "$(XCODEPROJ)" ]; then \
		xcodebuild -project "$(XCODEPROJ)" -scheme "$(SCHEME)" -configuration Release build; \
	else \
		echo "No .xcworkspace or .xcodeproj found."; exit 1; \
	fi

xcode-test:
	@if [ -n "$(XCWORKSPACE)" ]; then \
		xcodebuild test -workspace "$(XCWORKSPACE)" -scheme "$(SCHEME)" -destination 'platform=macOS' ; \
	elif [ -n "$(XCODEPROJ)" ]; then \
		xcodebuild test -project "$(XCODEPROJ)" -scheme "$(SCHEME)" -destination 'platform=macOS' ; \
	else \
		echo "No .xcworkspace or .xcodeproj found."; exit 1; \
	fi

help:
	@echo "Available targets:"
	@echo "  make build        # swift build"
	@echo "  make run          # swift run"
	@echo "  make test         # swift test"
	@echo "  make clean        # swift package clean + remove build dirs"
	@echo "  make ci           # clean, build, test"
	@echo "  make xcode-build  # xcodebuild if workspace/project present"
	@echo "  make xcode-test   # xcodebuild test if workspace/project present"
