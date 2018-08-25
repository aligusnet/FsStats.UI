DEV_JS=public/assets/js/fsstats.js
RELEASE_JS=public/assets/js/fsstats.min.js
ELM_BIN?=elm

ELMFILES = $(wildcard src/*.elm)

run: build
	$(ELM_BIN) reactor

build:
	$(ELM_BIN) make ${ELMFILES} --output=$(DEV_JS)

# npm install uglify-js -g
release:
	$(ELM_BIN) make ${ELMFILES} --output=$(RELEASE_JS) --optimize
	uglifyjs $(RELEASE_JS) --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=$(RELEASE_JS)

