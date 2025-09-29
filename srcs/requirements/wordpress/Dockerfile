# requirements/wordpress/Dockerfile
FROM debian:bullseye

# PHP-FPMとWordPressに必要なパッケージをインストール
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    wget \
    tar

# WordPressをダウンロード
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz

# PHP-FPMの設定
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php81/php-fpm.d/www.conf

EXPOSE 9000

# デーモンとして起動（フォアグラウンド）
CMD ["php-fpm81", "-F"]