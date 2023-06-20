
install:
	npm install
	raco pkg install --auto html-writing html-parsing scribble-math

build:
	mkdir docs || true
	rm -rf docs/*
	cp -r src/documents/* docs
	mkdir docs/posts
	cd src && racket generatewebsite.rkt
	cd src && racket generate-gravigon.rkt
	scribble --dest ./docs ./src/*.scrbl
	npx tsc

serve:
	cd docs && python3 -m http.server