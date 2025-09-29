#!/bin/bash

sleep 10

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."

    wp core download --allow-root

    wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --allow-root

    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception WordPress" \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --allow-root

    wp user create \
        ${WORDPRESS_USER} \
        ${WORDPRESS_USER_EMAIL} \
        --user_pass=${WORDPRESS_USER_PASSWORD} \
        --role=author \
        --allow-root

    chown -R www-data:www-data /var/www/html
fi

exec php-fpm7.4 -F