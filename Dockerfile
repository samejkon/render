# Sử dụng hình ảnh PHP với phiên bản phù hợp, ví dụ như 8.1
FROM php:8.1-fpm

# Cài đặt các tiện ích bổ sung nếu cần thiết, ví dụ: các extension PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Thiết lập thư mục làm việc
WORKDIR /var/www

# Copy tất cả các file từ thư mục gốc vào container
COPY . .

# Thiết lập quyền cho thư mục lưu trữ
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Chạy các lệnh cần thiết như cài đặt thư viện và migration
RUN composer install --no-dev --optimize-autoloader -vvv

RUN php artisan migrate --force
RUN php artisan config:cache
RUN php artisan route:cache

# Expose cổng mà ứng dụng sẽ lắng nghe
EXPOSE 9000

# Chạy PHP-FPM
CMD ["php-fpm"]
