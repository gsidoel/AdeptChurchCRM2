FROM php:8.2-apache

# Enable Apache rewrite module
RUN a2enmod rewrite \
 && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

RUN apt-get update && apt-get install -y \
    git unzip \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libicu-dev libxml2-dev \
    libcurl4-openssl-dev libonig-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
    bcmath curl gd gettext intl mbstring mysqli \
    opcache soap sodium xml zip

RUN a2enmod rewrite \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
 && sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html

# Ensure ChurchCRM image upload directories exist and are writable
RUN mkdir -p Images/Family Images/Person \
 && chown -R www-data:www-data Images \
 && chmod -R 775 Images

