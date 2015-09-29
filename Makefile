.PHONY: build run

build:
	docker build --rm=true -t mazelab/nginx-proxy .

run:
	docker run -P -it --rm=true --name proxy -v /var/run/docker.sock:/tmp/docker.sock:ro mazelab/nginx-proxy