
build:
	mkdir docs || true
	rm -rf docs/*
	cp -r src/documents/* docs
	mkdir docs/posts
	npx tsc
	cd src && racket generatewebsite.rkt
	cd src && racket generate-gravigon.rkt
	scribble --dest ./docs ./src/*.scrbl