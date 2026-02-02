FROM php:8.1-apache

# Set working dir
WORKDIR /var/www/html

# Install common extensions and utilities (modify if you need others)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Enable apache rewrite (if your app uses pretty URLs)
RUN a2enmod rewrite

# Copy app files
COPY . /var/www/html

# If composer.json exists, install dependencies
RUN if [ -f composer.json ]; then \
      php -r "copy('https://getcomposer.org/installer','composer-setup.php');" && \
      php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
      composer install --no-dev --optimize-autoloader && \
      rm -f composer-setup.php; \
    fi

# Fix permissions (optional tweak if needed)
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Default command runs Apache in foreground
CMD ["apache2-foreground"]