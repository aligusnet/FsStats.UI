ELM_JS=public/assets/js/fsstats.js

run: build
	elm-reactor

build:
	elm-make src/Normal.elm src/Bernoulli.elm src/Binomial.elm src/Poisson.elm src/Students.elm src/SummaryStatistics.elm --output=$(ELM_JS) --warn

# npm install uglify-js -g
compress:
	uglifyjs --compress --mangle --output=$(ELM_JS) -- $(ELM_JS)
