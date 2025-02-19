FROM php:8.1-apache

# Environment variables to reduce interactive prompts, etc.
ENV DEBIAN_FRONTEND=noninteractive

# define timezone
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
       # cli \ 
       #curl \ 
       #common \
       #json \ 
       pdo_mysql \  
       mysqli \
       intl \
       xml \ 
       mbstring \
       zip \
       soap \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-enable gd


# Enable Apache mod_rewrite
RUN a2enmod rewrite

# 3. Increase PHP limits by adding a custom .ini in /usr/local/etc/php/conf.d/
RUN echo "memory_limit=512M\n" \
         "upload_max_filesize=100M\n" \
         "post_max_size=100M\n" \
    > /usr/local/etc/php/conf.d/suitecrm.ini

# Copy any custom apache conf if desired
# COPY suitecrm.conf /etc/apache2/sites-available/000-default.conf

# Copy your entrypoint script (which handles SuiteCRM installation steps)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
