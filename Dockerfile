# Sử dụng hình ảnh PHP với phiên bản phù hợp
FROM php:8.1-fpm

# Cài đặt các tiện ích bổ sung nếu cần thiết
RUN apt-get update && apt-get install -y \
    nginx \
    ...

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Thiết lập thư mục làm việc
WORKDIR /var/www

# Copy tất cả các file từ thư mục gốc vào container
COPY . .

# Thiết lập quyền cho thư mục lưu trữ
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Cấu hình Nginx để lắng nghe cổng từ biến môi trường
COPY nginx.conf /etc/nginx/nginx.conf

# Expose cổng mà ứng dụng sẽ lắng nghe
EXPOSE 80

# Khởi động cả PHP-FPM và Nginx
CMD service php8.1-fpm start && nginx -g 'daemon off;'