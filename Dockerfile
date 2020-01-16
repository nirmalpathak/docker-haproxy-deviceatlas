FROM alpine:3.11

LABEL reference="https://github.com/haproxytech/haproxy-docker-alpine/blob/master/2.0/Dockerfile"
LABEL maintainer="Nirmal Pathak"

LABEL Name HAProxy DeviceAtlas
LABEL RUN /usr/bin/docker run -d -v /path/to/haproxy/config:/usr/local/etc/haproxy/config:ro IMAGE_NAME

ENV HAPROXY_BRANCH 2.0
ENV HAPROXY_MINOR 2.0.8
ENV HAPROXY_SHA256 c37e1e8515ad6f9781a0ac336ca88787f3bb52252fb2bdad9919ba16323c280a
ENV HAPROXY_SRC_URL http://www.haproxy.org/download
ENV DEVICEATLAS_VERSION 2.1.5

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

COPY ./deviceatlas-enterprise-c-$DEVICEATLAS_VERSION /usr/src/deviceatlas

RUN apk add --no-cache --virtual build-deps ca-certificates gcc libc-dev \
    linux-headers lua5.3-dev make openssl openssl-dev pcre-dev tar \
    zlib-dev curl shadow zlib lua5.3-libs && \
    curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy -j"$(nproc)" TARGET=linux-glibc CPU=generic USE_PCRE=1 PCREDIR= USE_REGPARM=1 USE_OPENSSL=1 \
                            USE_ZLIB=1 USE_TFO=1 USE_LINUX_TPROXY=1 USE_GETADDRINFO=1 \
                            USE_LUA=1 LUA_LIB=/usr/lib/lua5.3 LUA_INC=/usr/include/lua5.3 \
                            EXTRA_OBJS="contrib/prometheus-exporter/service-prometheus.o" \
                            USE_DEVICEATLAS=1 \
                            DEVICEATLAS_SRC=/usr/src/deviceatlas/Src \
                            all && \
    make -C /tmp/haproxy TARGET=linux2628 install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    chown "$HAPROXY_UID:$HAPROXY_GID" /var/lib/haproxy && \
    mkdir -p /usr/local/etc/haproxy/config && \
    ln -s /usr/local/etc/haproxy /etc/haproxy && \
    cp -R /tmp/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors && \
    rm -rf /tmp/haproxy && \
    apk del build-deps && \
    apk add --no-cache openssl zlib lua5.3-libs pcre && \
    rm -f /var/cache/apk/*

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

STOPSIGNAL SIGUSR1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/config/haproxy.cfg"]
