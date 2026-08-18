BIN = .build/release/aerospace-switcher

build:
	swift build -c release

install: build
	mkdir -p ~/.local/bin
	cp $(BIN) ~/.local/bin/aerospace-switcher

.PHONY: build install
