## Docker Base: Nginx


This repository contains **Dockerbase** of [Nginx](http://nginx.org/) for [Docker](https://www.docker.com/)'s [Dockerbase build](https://registry.hub.docker.com/u/dockerbase/nginx/) published on the public [Docker Hub Registry](https://registry.hub.docker.com/).


### Depends on:

* [dockerbase/service](https://registry.hub.docker.com/u/library/service/)


### Installation

1. Install [Docker](https://docs.docker.com/installation/).

2. Download [Dockerbase build](https://registry.hub.docker.com/u/dockerbase/nginx/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull dockerbase/nginx`


### Usage

    run:
        sudo docker run --restart=always -t --cidfile cidfile -d dockerbase/nginx /sbin/runit

    start:
        sudo docker start `cat cidfile`

    stop:
        sudo docker stop -t 10 `cat cidfile`
