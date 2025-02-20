FROM php:8.1-apache

# Environment variables to reduce interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Define timezone
ENV TZ=Australia/Sydney
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    unzip \
    zip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libzip-dev \
    openssl \
    git \
    cron \
    netcat-openbsd \
    && docker-php-ext-install \
       gd \
       pdo_mysql \  
       mysqli \
       intl \
       xml \ 
       mbstring \
       zip \
       soap \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-enable gd

# Enable Apache modules
RUN a2enmod rewrite headers ssl

# Increase PHP limits by adding a custom .ini
RUN echo "memory_limit=512M\n" \
         "upload_max_filesize=100M\n" \
         "post_max_size=100M\n" \
         "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE & ~E_WARNING\n" \
    > /usr/local/etc/php/conf.d/suitecrm.ini

# Configure Apache for SuiteCRM
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Add server name to avoid warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy your entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]