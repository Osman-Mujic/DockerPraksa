FROM php:7.4-apache

# Install necessary extensions and tools
RUN docker-php-ext-install pdo pdo_mysql zip bcmath && enable pdo pdo_mysql zip bcmath
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install intl
RUN docker-php-ext-install mysqlnd && docker-php-ext-enable mysqlnd
RUN apt-get update && apt-get upgrade -y
RUN docker-php-ext-install curl && docker-php-ext-enable curl
RUN docker-php-ext-install imagick && docker-php-ext-enable imagick
RUN docker-php-ext-install gd && docker-php-ext-enable gd
RUN docker-php-ext-install simplexml && docker-php-ext-enable simplexml
RUN docker-php-ext-install redis && docker-php-ext-enable redis
RUN docker-php-ext-install dom && docker-php-ext-enable dom
RUN docker-php-ext-install libxml && docker-php-ext-enable libxml
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini
RUN docker-php-ext-install json && docker-php-ext-enable json
RUN docker-php-ext-install mbstring && docker-php-ext-enable mbstring
RUN apt-get update && apt-get install -y supervisor

# Copy Apache and SSL configurations
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf
COPY ssl /etc/ssl/certs

# Enable Apache modules and SSL
RUN a2enmod proxy proxy_http ssl
RUN a2ensite default-ssl

# Copy the SSL generation script and make it executable
COPY generate_ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate_ssl.sh

# Set resource limits for Apache and PHP
RUN echo "php_admin_value[memory_limit] = 2G" >> /etc/php/7.4/apache2/php.ini
RUN echo "php_admin_value[opcache.memory_consumption] = 256" >> /etc/php/7.4/apache2/php.ini
RUN echo "php_admin_value[opcache.max_accelerated_files] = 20000" >> /etc/php/7.4/apache2/php.ini
RUN echo "php_admin_value[opcache.revalidate_freq] = 60" >> /etc/php/7.4/apache2/php.ini
RUN echo "MaxRequestWorkers 150" >> /etc/apache2/apache2.conf
RUN echo "ServerLimit 16" >> /etc/apache2/apache2.conf

# Start Supervisor
CMD ["/usr/bin/supervisord", "-n"]