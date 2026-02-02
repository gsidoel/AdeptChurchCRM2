# ============================================================
# ChurchCRM Dockerfile — WORKING BASELINE
#
# ✔ PHP 8.2
# ✔ All required PHP extensions installed
# ✔ All system dependencies resolved
#
# DO NOT MODIFY unless:
# - ChurchCRM version changes
# - PHP version changes
#
# Last verified: 2026-02-01
# ============================================================

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
# Image processing (ChurchCRM)
# -----------------------------
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y imagemagick \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Locales (required for translations)
# -----------------------------
RUN apt-get update && apt-get install -y \
    locales \
    && sed -i 's/# nl_NL.UTF-8 UTF-8/nl_NL.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
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

# NOTE:
# ChurchCRM checks for Apache mod_rewrite.
# This is correct for php:8.2-apache images.
# Reverse proxy (Traefik) will still handle routing.

# -----------------------------
# App files
# -----------------------------
COPY . /var/www/html/

# -----------------------------
# Permissions (baseline)
# -----------------------------
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# -----------------------------
# ChurchCRM runtime writeable directories
# -----------------------------
# ChurchCRM requires these directories to be writeable at runtime:
# - Images
# - Images/Family
# - Images/Person
# - Include/Config
#
# In Docker, these may not exist yet or may be owned by root.
# We explicitly create and relax permissions for these paths.
#
# This fixes:
# ❌ "Images directory is writable - Family"
# ❌ "Images directory is writable - Person"
#
RUN mkdir -p \
        /var/www/html/Images/Family \
        /var/www/html/Images/Person \
        /var/www/html/Include/Config \
    && chown -R www-data:www-data /var/www/html/Images \
    && chown -R www-data:www-data /var/www/html/Include/Config \
    && chmod -R 775 /var/www/html/Images \
    && chmod -R 775 /var/www/html/Include/Config

# -----------------------------
# Default locale
# -----------------------------
ENV LANG=nl_NL.UTF-8 \
    LANGUAGE=nl_NL:en_US \
    LC_ALL=nl_NL.UTF-8

# -----------------------------
# PHP sane defaults
# -----------------------------
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory.ini \
 && echo "upload_max_filesize=32M" >> /usr/local/etc/php/conf.d/memory.ini \
 && echo "post_max_size=32M" >> /usr/local/etc/php/conf.d/memory.ini
