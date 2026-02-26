
.PHONY: all run clean install

all:
	cargo build --release

run:
	cargo run --release

clean:
	cargo clean

install:
	sudo apt install -y unixodbc-dev
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	. ~/.cargo/env
