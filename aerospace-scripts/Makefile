BIN = target/release/aerospace-scripts

build:
	cargo build --release

install: build
	mkdir -p ~/.local/bin
	cp $(BIN) ~/.local/bin/aerospace-scripts

.PHONY: build install
