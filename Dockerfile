# VERSION 1.1
# DOCKER-VERSION  1.2.0
# AUTHOR:         Richard Lee <lifuzu@gmail.com>
# DESCRIPTION:    Ubuntu Image Container

FROM dockerbase/service

MAINTAINER Richad Lee "lifuzu@gmail.com"

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Run the build scripts
RUN	apt-get update

# Information Of Package
ENV	PKG_NAME nginx
ENV	PKG_KEY http://nginx.org/keys/nginx_signing.key

# Install Nginx
RUN     wget -q -O - $PKG_KEY | sudo apt-key add -
RUN     echo deb http://nginx.org/packages/ubuntu/ trusty nginx > /etc/apt/sources.list.d/$PKG_NAME.list
RUN     apt-get update
RUN     apt-get install -y --no-install-recommends $PKG_NAME

RUN	echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
        chown -R www-data:www-data /usr/share/nginx
RUN     mkdir -p /etc/service/$PKG_NAME
ADD     build/runit/$PKG_NAME /etc/service/$PKG_NAME/run

# Clean up system
RUN	apt-get clean
RUN	rm -rf /tmp/* /var/tmp/*
RUN	rm -rf /var/lib/apt/lists/*

# Define mountable directories.
VOLUME 	["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx"]

# for main ports:
EXPOSE  80 
EXPOSE  443 

# Set environment variables.
ENV     HOME /root

# Define working directory.
WORKDIR /etc/nginx

# Define default command.
CMD ["bash"]

