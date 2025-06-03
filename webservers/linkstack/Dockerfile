FROM alpine:3.19.1
LABEL maintainer="kubelize@kubelize.com"
LABEL description="LinkStack Docker by kubelize"

# Setup apache and php
RUN apk --no-cache --update \
    add apache2 \
    curl \
    php82-apache2 \
    php82-bcmath \
    php82-bz2 \
    php82-calendar \
    php82-common \
    php82-ctype \
    php82-curl \
    php82-dom \
    php82-fileinfo \
    php82-gd \
    php82-iconv \
    php82-json \
    php82-mbstring \
    php82-mysqli \
    php82-mysqlnd \
    php82-openssl \
    php82-pdo_mysql \
    php82-pdo_pgsql \
    php82-pdo_sqlite \
    php82-phar \
    php82-session \
    php82-xml \
    php82-tokenizer \
    php82-zip \
    php82-xmlwriter \
    php82-redis \
    tzdata \
    && mkdir /htdocs

# App source
COPY linkstack /htdocs

# Default configs into /config
COPY config/apache2/httpd.conf /config/apache2/httpd.conf
COPY config/php82/php.ini /config/php82/php.ini

# Permissions for htdocs
RUN chown -R apache:apache /htdocs \
 && find /htdocs -type d -print0 | xargs -0 chmod 0755 \
 && find /htdocs -type f -print0 | xargs -0 chmod 0644

# Create and fix permissions for override + debug + log dirs
RUN mkdir -p /config/apache2/conf.d /config/php82 /debug && \
    chown -R apache:apache /config /debug && \
    chmod -R 0775 /config /debug

# Entrypoint
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER apache:apache

WORKDIR /htdocs

CMD ["docker-entrypoint.sh"]
