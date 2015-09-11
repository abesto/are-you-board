TSLINT=node_modules/tslint/bin/tslint
TSC=node_modules/typescript/bin/tsc
WATCHMAN=node_modules/watchman/watchman
DOCKER_COMPOSE=docker-compose
DOCKER=docker

CLIENT_TS=$(shell find client/src/ts -name '*.ts' | grep -v '\.d\.ts')
CLIENT_JS=client/build/js/app.js
CLIENT_JS_MAP=client/build/js/app.js.map
CLIENT_STATIC_SRC=$(shell find client/src/static -type f)
CLIENT_STATIC_DST=$(patsubst client/src/static/%,client/build/%,${CLIENT_STATIC_SRC})
CLIENT_LIB_SRC=$(shell find client/lib/bower_components -type f)
CLIENT_LIB_DST=$(patsubst client/lib/bower_components/%,client/build/lib/%,${CLIENT_LIB_SRC})
CLIENT_DIRS=$(sort $(dir ${CLIENT_JS} ${CLIENT_STATIC_DST} ${CLIENT_LIB_DST}))

SERVER_TS=$(shell find server/src/ts -name '*.ts' | grep -v '\.d\.ts')
SERVER_JS=$(patsubst server/src/ts/%.ts,server/build/%.js,${SERVER_TS})
SERVER_FILES=${SERVER_JS} server/build/package.json server/build/api/swagger/swagger.yaml server/build/api/config/default.yaml
SERVER_DIRS=$(sort $(dir ${SERVER_FILES}))

all: client server docker

client: ${CLIENT_DIRS} ${CLIENT_LIB_DST} ${CLIENT_STATIC_DST} ${CLIENT_JS}

${CLIENT_DIRS} ${SERVER_DIRS}:
	mkdir -p $@

${CLIENT_JS_MAP} ${CLIENT_JS}: ${CLIENT_TS}
	${TSLINT} ${CLIENT_TS}
	${TSC} --out ${CLIENT_JS} --sourcemap ${CLIENT_TS}

client/build/%: client/src/static/%
	cp $< $@

client/build/lib/%: client/lib/bower_components/%
	cp $< $@

server: server/build ${SERVER_DIRS} ${SERVER_FILES}

server/build/%.js: server/src/ts/%.ts
	${TSLINT} $<
	${TSC} --module commonjs --outDir $(dir $@) $<

server/build/package.json: server/src/package.json
	cp server/src/package.json $@

server/build/api/swagger/swagger.yaml: server/src/swagger/api/swagger/swagger.yaml
	cp $< $@

server/build/api/config/default.yaml: server/src/swagger/config/default.yaml
	cp $< $@

clean:
	-rm -r client/build
	-rm -r server/build

docker:
	${DOCKER_COMPOSE} build

watch/server:
	${WATCHMAN} server/src "make server"

watch/client:
	${WATCHMAN} client/src "make client"

watch: watch/client watch/server


.PHONY: app client server clean docker runserver console

