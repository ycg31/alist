FROM alpine:edge as builder
LABEL stage=go-builder
WORKDIR /app/
COPY ./ ./
RUN apk add --no-cache bash git go gcc musl-dev curl; \
    bash build.sh release docker

FROM alpine:edge
LABEL MAINTAINER="i@nn.ci"
VOLUME /opt/alist/data/
WORKDIR /opt/alist/
COPY --from=builder /app/bin/alist ./
COPY docker-entrypoint.sh /entrypoint.sh
RUN apk add \
    ca-certificates \
    bash \
    su-exec && \
    chmod +x /entrypoint.sh
RUN  mkdir -p /www/cgi-bin
RUN  mkdir -p /opt/alist/data/www
COPY data.db /opt/alist/data/data.db
COPY config.json /opt/alist/data/config.json
COPY token /token
RUN  touch /mytoken.txt
COPY updateall /updateall 
COPY search /www/cgi-bin/search
COPY header.html /www/cgi-bin/header.html
COPY nginx.conf /etc/nginx/http.d/default.conf
RUN  set -ex   && \
     apk add --update --no-cache \
     sqlite \
     unzip \
     bash \
     gzip \
     ripgrep \
     busybox-extras \
     nginx  && \
     rm -rf /tmp/* /var/cache/apk/*
RUN  mv /usr/bin/rg /bin/grep
EXPOSE 5244
ENV PUID=0 PGID=0 UMASK=022
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./alist" "server" "--no-prefix"]
