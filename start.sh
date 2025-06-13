#!/bin/bash

echo "Starting application setup script..."

echo "Starting MySQL server..."
mysqld_safe &

# Wait for MySQL to be available
#echo "Waiting for MySQL to start..."
#until mysql -h 127.0.0.1 -u root -p"" -e "select 1" > /dev/null 2>&1; do
#  echo "MySQL is unavailable - sleeping"
#  sleep 1
#done
until mysqladmin ping --silent; do
    echo "Waiting for MySQL to start..."
    sleep 2
done
echo "MySQL is up and running!"

# Configure MySQL: Create database and user (this is very basic for a single container)
# In a real setup, avoid hardcoding passwords and use secure methods.
echo "Creating MySQL database and user..."
# Run the SQL script to create database and user
mysql < /init-db.sql
echo "MySQL database and user configured."

# Update Laravel .env for in-container database connection
#echo "Updating .env for in-container database connection..."
#sed -i 's/DB_CONNECTION=.*$/DB_CONNECTION=mysql/' .env
#sed -i 's/DB_HOST=.*$/DB_HOST=127.0.0.1/' .env
#sed -i 's/DB_PORT=.*$/DB_PORT=3306/' .env
sed -i 's/DB_DATABASE=.*$/DB_DATABASE=laravel/' .env
sed -i 's/DB_USERNAME=.*$/DB_USERNAME=laravel/' .env
sed -i 's/DB_PASSWORD=.*$/DB_PASSWORD=laravel/' .env

# Generate Laravel application key if not already set
if [ -z "$APP_KEY" ]; then
    echo "Generating Laravel application key..."
    php artisan key:generate
else
    echo "Using APP_KEY from environment variable."
    php artisan key:generate --force # Force re-generate if an old key exists in .env but new one is passed
fi

# Run Laravel migrations
echo "Running Laravel migrations..."
php artisan migrate --force


echo "ServerName localhost" >> /etc/apache2/apache2.conf
apache2ctl -D FOREGROUND

npm install
npm run build &

echo "Application setup complete."


# Optional: set ServerName to avoid warnings

# The main supervisor command takes over from here