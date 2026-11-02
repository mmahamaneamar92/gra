#!/usr/bin/env sh
set -e

cd /var/www/html

if [ ! -f .env ]; then
    cp .env.example .env
fi

# OCI8 n'est pas installé dans l'image Docker de développement.
# L'extension reste obligatoire sur le serveur Windows/Laragon de production.
composer install --no-interaction --prefer-dist --ignore-platform-req=ext-oci8

if ! grep -q '^APP_KEY=base64:' .env; then
    php artisan key:generate --ansi
fi

php artisan migrate --force --no-interaction
php artisan db:seed --force --no-interaction

exec "$@"
