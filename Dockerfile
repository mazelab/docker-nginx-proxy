FROM nginx:1.7.11
MAINTAINER https://m-ko-x.de Markus Kosmal <code@m-ko-x.de>

# install packages
RUN apt-get update -y -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    wget \
    cron \
 && apt-get clean -y -qq \
 && rm -r /var/lib/apt/lists/*
 
 # Install Forego
RUN wget -P /usr/local/bin -q https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.3.9

RUN wget -q https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

 # add late as tmpl is most modified part and less content needs to be rebuilt
ADD ./conf/nginx.tmpl /app/
ADD ./conf/Procfile /app/

RUN rm -f /etc/nginx/nginx.conf
ADD ./conf/nginx.conf /etc/nginx/

ADD ./conf/rotate_nginx_log.sh /usr/local/sbin/rotate_nginx_log.sh
RUN chmod +x /usr/local/sbin/rotate_nginx_log.sh

#RUN mkdir -p /tmp
#RUN crontab -l > /tmp/tmpcron
RUN mkdir -p /etc/cron.d
RUN echo "* 1 * * * /usr/local/sbin/rotate_nginx_log.sh" >> /etc/cron.d/nginx_log
#RUN crontab /tmp/tmpcron
#RUN rm -f /tmp/tmpcron

WORKDIR /app/

# set max size within a body
ENV GLOB_MAX_BODY_SIZE 10m

# enable bundle support to provide nginx CA chain
# have a look at http://nginx.org/en/docs/http/configuring_https_servers.html#chains
# for more info
ENV GLOB_SSL_CERT_BUNDLE_INFIX ""

# set default session timeout
ENV GLOB_SSL_SESSION_TIMEOUT 5m

# set default shared session cache
ENV GLOB_SSL_SESSION_CACHE 50m

# activate SPDY support
# more info https://www.mare-system.de/guide-to-nginx-ssl-spdy-hsts/
ENV GLOB_SPDY_ENABLED "0"

# default return code for errors
ENV GLOB_HTTP_NO_SERVICE 503

# redirect prefixed to non prefix
ENV GLOB_AUTO_REDIRECT_ENABLED "0"

# set prefix to be used for auto redirect
ENV GLOB_AUTO_REDIRECT_PREFIX www

# set direction
# - 0: redirect from prefix to non-prefix
# - 1: redirect from non-prefix to prefix
ENV GLOB_AUTO_REDIRECT_DIRECTION "0"

# Only allow ssl
ENV GLOB_HTTPS_FORCE "1"

# Allow to use http only if https is not available
ENV GLOB_ALLOW_HTTP_FALLBACK "0"

# connect to docker host via socket by default
ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs","/etc/nginx/htpasswd","/etc/nginx/vhost.d/","/etc/nginx/conf.d/"]

CMD ["forego", "start", "-r"]
