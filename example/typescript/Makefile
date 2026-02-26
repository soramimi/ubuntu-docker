
.PHONY: all run clean install deps

all:
	npm run build

run:
	npm run build && node dist/main.js

clean:
	-rm -rf dist node_modules

deps:
	npm install

install:
	sudo apt install -y nodejs npm unixodbc-dev
	npm install
