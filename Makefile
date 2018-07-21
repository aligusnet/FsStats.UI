ELM_JS=public/assets/js/fsstats.js

ELMFILES = $(wildcard src/*.elm)

run: build
	elm-reactor

build:
	elm-make ${ELMFILES} --output=$(ELM_JS) --warn

# npm install uglify-js -g
compress:
	uglifyjs --compress --mangle --output=$(ELM_JS) -- $(ELM_JS)
