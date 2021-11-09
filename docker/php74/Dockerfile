FROM php:7.4-fpm

WORKDIR /var/www/html

ADD ./docker/php74/php.ini /usr/local/etc/php/conf.d/99-docker.ini

# App install
ENV NODE_VERSION=16
RUN apt update \
    && apt install -y nodejs apt-utils unzip libzip-dev mariadb-client postgresql-client \
    && pecl install redis \
    && docker-php-ext-install zip pdo_mysql \
    && curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -  \
    && apt -y autoremove \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Composer install
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

EXPOSE 9000
