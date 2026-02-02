#!/bin/sh
set -e

echo "ChurchCRM: fixing runtime permissions..."

# These paths may be volumes
mkdir -p /var/www/html/Images \
         /var/www/html/tmp_attach \
         /var/www/html/Include/Config

chown -R www-data:www-data \
    /var/www/html/Images \
    /var/www/html/tmp_attach \
    /var/www/html/Include/Config

chmod -R 775 \
    /var/www/html/Images \
    /var/www/html/tmp_attach \
    /var/www/html/Include/Config

exec "$@"
