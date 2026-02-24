NAME := example

.PHONY: all run clean install deps

all:
	go build -o $(NAME) .

run:
	go run .

clean:
	-rm -f $(NAME)

deps:
	go get github.com/alexbrainman/odbc@latest
	go mod tidy

install:
	sudo apt install -y golang unixodbc-dev
	go get github.com/alexbrainman/odbc
