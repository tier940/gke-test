FROM php:8.0-fpm

WORKDIR /var/www/html

ADD ./docker/php80/php.ini /usr/local/etc/php/conf.d/99-docker.ini

# App install
ENV DEBCONF_NOWARNINGS=yes
ENV NODE_VERSION=16
RUN apt-get update \
    && apt-get install -y nodejs apt-utils unzip libzip-dev mariadb-client postgresql-client \
    && pecl install redis \
    && docker-php-ext-install zip pdo_mysql \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -  \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Composer install
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

EXPOSE 9000
