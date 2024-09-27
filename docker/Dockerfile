FROM php:apache
RUN a2enmod rewrite
RUN a2enmod mime
COPY ./html /var/www/html
COPY ./src /var/www/html
