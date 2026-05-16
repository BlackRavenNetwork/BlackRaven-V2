FROM debian:stretch
LABEL maintainer="BlackRaven Developers <admin@blackraven.net>"
LABEL description="Dockerised BlackRavenCore, built from Travis"

RUN apt-get update && apt-get -y upgrade && apt-get clean && rm -fr /var/cache/apt/*

COPY bin/* /usr/bin/
