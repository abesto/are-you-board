SERVER_SOURCES := $(wildcard server/**.go)

server/server: ${SERVER_SOURCES}
	cd server && go build

watch-server:
	cd server && gin --immediate --port 8080

watch-client:
	cd client && gopherjs build --watch

.PHONY: run-server watch-client
