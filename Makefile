CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)
GARDEN_BIN ?= $(shell which garden)
PREFIX ?= /usr/local

all: clean build

build:
	$(SHARDS_BIN)
	$(CRYSTAL_BIN) build --release -o bin/garden src/garden/bootstrap.cr $(CRFLAGS)

clean:
	rm -f ./bin/garden

test:
	$(CRYSTAL_BIN) spec --verbose

spec: test

install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/garden $(PREFIX)/bin

reinstall: build
	cp -rf ./bin/garden $(GARDEN_BIN)

.PHONY: all build clean test spec install reinstall
