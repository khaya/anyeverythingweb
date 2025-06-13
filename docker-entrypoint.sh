#!/bin/sh

# Start MySQL service (for single container only)
mysqld_safe --datadir=/var/lib/mysql &

# Wait for MySQL to be ready
echo "Waiting for MySQL to start..."
until mysqladmin ping -h "127.0.0.1" --silent; do
    sleep 1
done

# Laravel setup (run once)
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start PHP-FPM (or any process manager you prefer)
exec php-fpm
