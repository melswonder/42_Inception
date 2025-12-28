#!/bin/bash

set -e

cd /var/www/html

# MariaDBが起動するまで待機（sleepを使わない方法）
echo "Waiting for MariaDB to be ready..."
RETRIES=30
until mysqladmin ping -h"${WORDPRESS_DB_HOST%:*}" --silent 2>/dev/null; do
    RETRIES=$((RETRIES - 1))
    if [ $RETRIES -eq 0 ]; then
        echo "Failed to connect to MariaDB"
        exit 1
    fi
    echo "MariaDB is unavailable - waiting (${RETRIES} retries left)"
    sleep 2
done
echo "MariaDB is up"

# WordPressがまだダウンロードされていない場合のみダウンロード
if [ ! -f wp-includes/version.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
fi

# wp-config.phpが存在しない場合のみ作成
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --allow-root
fi

# WordPressがまだインストールされていない場合のみインストール
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception WordPress" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --allow-root

    # 通常ユーザーを作成
    echo "Creating WordPress user..."
    wp user create \
        ${WORDPRESS_USER} \
        ${WORDPRESS_USER_EMAIL} \
        --user_pass=${WORDPRESS_USER_PASSWORD} \
        --role=author \
        --allow-root

    echo "WordPress setup completed"
else
    echo "WordPress is already installed"
fi

# 権限を設定
chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."
# PHP-FPMをフォアグラウンドで起動
exec php-fpm7.4 -F