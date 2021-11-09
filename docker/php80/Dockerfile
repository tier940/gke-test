FROM php:8.0-fpm

WORKDIR /var/www/html

ADD ./docker/php80/php.ini /usr/local/etc/php/conf.d/99-docker.ini
RUN apt update \
    && apt install -y apt-utils unzip libzip-dev mariadb-client postgresql-client \
    && pecl install redis \
    && docker-php-ext-install zip pdo_mysql \
    && apt -y autoremove \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Composer install
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

# Node install
ENV NODE_VERSION=16
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt install -y nodejs

EXPOSE 9000
