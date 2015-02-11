SHELL := /bin/bash
VERSION = `cat VERSION | head -n 1`

all: docker getfig

getfig:
	@curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > ./fig
	@chmod 755 ./fig

docker: docker-influxdb docker-graphana

docker-influxdb:
	@docker build -t influxdb:${VERSION} --rm=true ./InfluxDB-Docker/

docker-graphana:
	@docker build -t graphana:${VERSION} --rm=true ./graphana-docker/

run: docker getfig
	@./fig rm --force
	@./fig up

clean: clean-influxdb clean-graphana

clean-influxdb:
	@docker ps -a | grep "influxdb.*" | awk '{print $1}' | xargs -r docker rm -f
	@docker images | grep "influxdb.*" | sed 's@^\([^ ]*\) *\([^ ]*\) *.*@\1:\2@g' | xargs -r docker rmi

clean-graphana:
	@docker ps -a | grep "graphana.*" | awk '{print $1}' | xargs -r docker rm -f
	@docker images | grep "graphana.*" | sed 's@^\([^ ]*\) *\([^ ]*\) *.*@\1:\2@g' | xargs -r docker rmi

.PHONY: docker getfig clean
