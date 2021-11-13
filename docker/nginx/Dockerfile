FROM nginx:stable-alpine

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/
RUN mkdir -p /var/www/html/public

EXPOSE 80
