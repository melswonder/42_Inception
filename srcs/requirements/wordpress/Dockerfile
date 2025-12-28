# requirements/wordpress/Dockerfile
FROM debian:bullseye

# PHP-FPMとWordPressに必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysqli \
    php7.4-curl \
    php7.4-dom \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-gd \
    php7.4-intl \
    php7.4-bcmath \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# WP-CLIをインストール
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# PHP-FPMの設定ディレクトリを作成
RUN mkdir -p /run/php

# PHP-FPM設定ファイルをコピー
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# セットアップスクリプトをコピー
COPY ./tools/setup_wordpress.sh /usr/local/bin/setup_wordpress.sh
RUN chmod +x /usr/local/bin/setup_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

# セットアップスクリプトを実行
CMD ["/usr/local/bin/setup_wordpress.sh"]