# Use Ubuntu as base image
FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    apache2 \
    libapache2-mod-php \
    php \
    php-mysql \
    php-mbstring \
    php-xml \
    php-zip \
    php-gd \
    php-curl \
    php-bcmath \
    mysql-server \
    mysql-client \
    composer \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure Apache
RUN a2enmod rewrite
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Set working directory
WORKDIR /var/www/html

# Clone the Laravel application from GitHub
# Note: For private repos, you'll need to handle SSH keys or use a personal access token
#RUN git clone https://github.com/khaya/anyeverythingweb.git /tmp/anyeverythingweb \
#    && git config --global --add safe.directory /var/www/html

COPY . /tmp/anyeverythingweb    
RUN mv /tmp/anyeverythingweb/* /var/www/html/ \
    && rm -rf /tmp/anyeverythingweb 

# Install PHP dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Install Node.js dependencies and build assets
#RUN npm install --prefix /var/www/html \
#    && npm run build --prefix /var/www/html 

# Copy environment file and generate key
COPY .env.example .env
RUN php artisan key:generate

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

#Copy Mysql initialization script
COPY init-db.sql /init-db.sql

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port 80
EXPOSE 80
EXPOSE 5174

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

# Start services
CMD ["/start.sh"]