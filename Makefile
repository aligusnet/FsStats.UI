ELM_JS=public/assets/js/fsstats.js

run: build
	elm-reactor

build:
	elm-make src/Normal.elm --output=$(ELM_JS) --warn

# npm install uglify-js -g
compress:
	uglifyjs --compress --mangle --output=$(ELM_JS) -- $(ELM_JS)
