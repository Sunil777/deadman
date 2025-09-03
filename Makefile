BINARY := deadman
BUILD_DIR := bin
INSTALL_DIR ?= /usr/local/bin

.PHONY: all build install uninstall clean docker

all: build

build:
	mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-s -w -static"' -o $(BUILD_DIR)/$(BINARY) .

install: build
	install -d $(INSTALL_DIR)
	install -m 0755 $(BUILD_DIR)/$(BINARY) $(INSTALL_DIR)/$(BINARY)

uninstall:
	rm -f $(INSTALL_DIR)/$(BINARY)

clean:
	rm -rf $(BUILD_DIR)

docker:
	docker build -t deadman .