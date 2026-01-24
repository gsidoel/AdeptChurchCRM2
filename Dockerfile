FROM php:8.2-apache

# -------------------------------------------------
# System packages required by ChurchCRM
# -------------------------------------------------
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------
# PHP extensions required by ChurchCRM
# -------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
    bcmath \
    curl \
    gd \
    gettext \
    intl \
    mbstring \
    mysqli \
    opcache \
    soap \
    sodium \
    xml \
    zip

# -------------------------------------------------
# Apache configuration
# -------------------------------------------------
RUN a2enmod rewrite \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Allow ChurchCRM to use .htaccess
RUN sed -i 's/AllowOverride None/AllowOverride All/' \
    /etc/apache2/apache2.conf

# -------------------------------------------------
# Install Composer
# -------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -------------------------------------------------
# Application
# -------------------------------------------------
WORKDIR /var/www/html
COPY . .

# -------------------------------------------------
# Install PHP dependencies
# -------------------------------------------------
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction

# -------------------------------------------------
# Permissions required by ChurchCRM
# -------------------------------------------------
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html \
 && chmod -R 775 Images PrivateData Include \
 && chmod 664 Include/Config.php || true
