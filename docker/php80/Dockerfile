FROM php:8.0-fpm

USER www
WORKDIR /var/www/html

ADD php.ini /usr/local/etc/php/conf.d/99-docker.ini
RUN apt update \
    && apt install -y git unzip bash-completion libzip-dev mariadb-client postgresql-client \
    && pecl install xdebug redis \
    && docker-php-ext-install zip pdo_mysql \
    && docker-php-ext-enable xdebug \
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
    && apt install -y nodejs \
    && npm install -g yarn npm-check-updates
