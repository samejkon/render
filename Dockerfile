# Sử dụng official PHP image với phiên bản phù hợp và Apache
FROM php:8.2-apache

# Cài đặt các extension cần thiết cho Laravel
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cài đặt Node.js và npm nếu bạn sử dụng frontend assets trong Laravel
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Cấu hình Apache
RUN a2enmod rewrite

# Thiết lập thư mục làm việc
WORKDIR /var/www/html

# Copy code Laravel vào container
COPY . .

# Chmod thư mục storage và bootstrap/cache để đảm bảo có quyền ghi
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Tạo file database.sqlite nếu sử dụng SQLite
RUN touch /var/www/html/database/database.sqlite

# Cài đặt các package PHP với Composer
RUN composer install --optimize-autoloader --no-dev

# Cài đặt frontend assets (nếu có)
# RUN npm install && npm run prod

# Copy file cấu hình Apache
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80 để Apache có thể lắng nghe
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
