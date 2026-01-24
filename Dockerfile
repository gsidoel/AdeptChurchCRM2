FROM php:8.2-apache

# -----------------------------
# System dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libsodium-dev \
    libonig-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# PHP extensions (ChurchCRM)
# -----------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        bcmath \
        gd \
        gettext \
        intl \
        mbstring \
        mysqli \
        pdo \
        pdo_mysql \
        opcache \
        soap \
        sodium \
        xml \
        zip

# -----------------------------
# Apache
# -----------------------------
RUN a2enmod rewrite

# -----------------------------
# App files
# -----------------------------
COPY . /var/www/html/

# -----------------------------
# Permissions
# -----------------------------
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# -----------------------------
# PHP sane defaults
# -----------------------------
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory.ini \
 && echo "upload_max_filesize=32M" >> /usr/local/etc/php/conf.d/memory.ini \
 && echo "post_max_size=32M" >> /usr/local/etc/php/conf.d/memory.ini
